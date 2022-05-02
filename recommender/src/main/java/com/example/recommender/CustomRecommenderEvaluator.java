package com.example.recommender;

import org.apache.mahout.cf.taste.common.TasteException;
import org.apache.mahout.cf.taste.eval.IRStatistics;
import org.apache.mahout.cf.taste.eval.RecommenderBuilder;
import org.apache.mahout.cf.taste.eval.RecommenderEvaluator;
import org.apache.mahout.cf.taste.eval.RecommenderIRStatsEvaluator;
import org.apache.mahout.cf.taste.impl.eval.GenericRecommenderIRStatsEvaluator;
import org.apache.mahout.cf.taste.impl.eval.RMSRecommenderEvaluator;
import org.apache.mahout.cf.taste.model.DataModel;

public class CustomRecommenderEvaluator {

    private final RecommenderBuilder recommenderBuilder;
    private final DataModel model;

    public CustomRecommenderEvaluator(RecommenderBuilder recommenderBuilder, DataModel model) {
        this.recommenderBuilder = recommenderBuilder;
        this.model = model;
    }

    public void compute_recommender_RMSE(double training_percentage) throws TasteException {
        RecommenderEvaluator evaluator = new RMSRecommenderEvaluator();
        double score = evaluator.evaluate(recommenderBuilder, null, model, training_percentage, 1.0 - training_percentage);
        System.out.println("RMSE: " + score);
    }

    public void compute_recommender_F1score(int at,
                                            double relevanceThreshold,
                                            double evaluationPercentage) throws TasteException {

        RecommenderIRStatsEvaluator statsEvaluator = new GenericRecommenderIRStatsEvaluator();
        IRStatistics stats = statsEvaluator.evaluate(recommenderBuilder, null, model, null,
                at, relevanceThreshold, evaluationPercentage);

        System.out.println("Precision: " + stats.getPrecision());
        System.out.println("Recall: " + stats.getRecall());
        System.out.println("F1 Score: " + stats.getF1Measure());
    }
}
