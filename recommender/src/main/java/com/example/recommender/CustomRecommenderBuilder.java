package com.example.recommender;

import org.apache.mahout.cf.taste.common.TasteException;
import org.apache.mahout.cf.taste.eval.RecommenderBuilder;
import org.apache.mahout.cf.taste.impl.neighborhood.NearestNUserNeighborhood;
import org.apache.mahout.cf.taste.impl.recommender.GenericItemBasedRecommender;
import org.apache.mahout.cf.taste.impl.recommender.GenericUserBasedRecommender;
import org.apache.mahout.cf.taste.impl.similarity.*;
import org.apache.mahout.cf.taste.model.DataModel;
import org.apache.mahout.cf.taste.neighborhood.UserNeighborhood;
import org.apache.mahout.cf.taste.recommender.Recommender;
import org.apache.mahout.cf.taste.similarity.ItemSimilarity;
import org.apache.mahout.cf.taste.similarity.UserSimilarity;

public class CustomRecommenderBuilder implements RecommenderBuilder {

    private final String type;            // One of ['user', 'item']
    private final String similarity_name; //The name of the similarity measure. One of ['pearson', 'log-likelihood', 'tanimoto',
                                    //'euclidean', 'spearman'] (The last one only for User-based recommender).
    private final int k_neighbours;       //Specifies the nearest K users to a given user (only for User-based recommender).

    public CustomRecommenderBuilder(String type, String similarity_name, int k_neighbours) {
        this.type = type;
        this.similarity_name = similarity_name;
        this.k_neighbours = k_neighbours;
    }

    /**
     * This function returns a User-based recommender using one of the availables similarity measures.
     * @param model A DataModel object.
     * @return GenericUserBasedRecommender object
     * @throws TasteException Exception while creating the object.
     */
    public GenericUserBasedRecommender build_user_based_recommender(DataModel model) throws TasteException {
        UserSimilarity similarity = null;

        switch (similarity_name) {
            case "pearson":
                similarity = new PearsonCorrelationSimilarity(model);
                break;
            case "log-likelihood":
                similarity = new LogLikelihoodSimilarity(model);
                break;
            case "tanimoto":
                similarity = new TanimotoCoefficientSimilarity(model);
                break;
            case "euclidean":
                similarity = new EuclideanDistanceSimilarity(model);
                break;
            case "spearman":
                similarity = new SpearmanCorrelationSimilarity(model);
            default:
                System.out.println("Similarity name is incorrect! It must be one of ['pearson', 'log-likelihood', " +
                        "'tanimoto', 'euclidean', 'spearman']");
                break;
        }

        if (similarity == null){
            System.out.println("Setting similarity measure to LogLikelihood since no other provided.");
            similarity = new LogLikelihoodSimilarity(model);
        }

        // computes [k_neighbours] nearest neighbors
        UserNeighborhood neighborhood = new NearestNUserNeighborhood(k_neighbours, similarity, model);

        return new GenericUserBasedRecommender(model, neighborhood, similarity);
    }

    /**
     * This function returns a Item-based recommender using one of the availables similarity measures.
     * @param model A DataModel object.
     * @return GenericItemBasedRecommender object
     * @throws TasteException Exception while creating the object.
     */
    public GenericItemBasedRecommender build_item_based_recommender(DataModel model) throws TasteException {
        ItemSimilarity similarity = null;

        switch (similarity_name) {
            case "pearson":
                similarity = new PearsonCorrelationSimilarity(model);
                break;
            case "log-likelihood":
                similarity = new LogLikelihoodSimilarity(model);
                break;
            case "tanimoto":
                similarity = new TanimotoCoefficientSimilarity(model);
                break;
            case "euclidean":
                similarity = new EuclideanDistanceSimilarity(model);
            default:
                System.out.println("Similarity name is incorrect! It must be one of ['pearson', 'log-likelihood', " +
                        "'tanimoto', 'euclidean']");
                break;
        }

        if (similarity == null){
            System.out.println("Setting similarity measure to LogLikelihood since no other provided.");
            similarity = new LogLikelihoodSimilarity(model);
        }

        return new GenericItemBasedRecommender(model, similarity);
    }

    /**
     * Builds a Recommender object (User-based or Item-based)
     * @param model A DataModel object.
     * @return Recommender object.
     * @throws TasteException Exception while creating the object.
     */
    public Recommender build_recommender(DataModel model) throws TasteException {
        if (type.equals("user")) {
            return build_user_based_recommender(model);
        } else {
            return build_item_based_recommender(model);
        }
    }

    @Override
    public Recommender buildRecommender(DataModel dataModel) throws TasteException {
        return build_recommender(dataModel);
    }
}
