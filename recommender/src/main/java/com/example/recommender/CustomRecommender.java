package com.example.recommender;

import org.apache.mahout.cf.taste.common.TasteException;
import org.apache.mahout.cf.taste.eval.IRStatistics;
import org.apache.mahout.cf.taste.eval.RecommenderEvaluator;
import org.apache.mahout.cf.taste.eval.RecommenderIRStatsEvaluator;
import org.apache.mahout.cf.taste.impl.eval.GenericRecommenderIRStatsEvaluator;
import org.apache.mahout.cf.taste.impl.eval.RMSRecommenderEvaluator;
import org.apache.mahout.cf.taste.impl.model.file.FileDataModel;
import org.apache.mahout.cf.taste.model.DataModel;
import org.apache.mahout.cf.taste.recommender.RecommendedItem;
import org.apache.mahout.cf.taste.recommender.Recommender;

import java.io.File;
import java.io.IOException;
import java.util.List;

public class CustomRecommender {


    public static void main(String args[]) throws IOException, TasteException {
        try{
            //Creating data model
            DataModel datamodel = new FileDataModel(new File("C:\\Users\\david\\Documents\\Master Ingenieria Informatica\\MAGVD\\db_export\\magvd_public_valoracion_parsed.csv")); //data

            //Recommender recommender = build_recommender(datamodel, "user", "log-likelihood", 20);
            CustomRecommenderBuilder recommenderBuilder = new CustomRecommenderBuilder("user", "log-likelihood", 20);

            Recommender recommender = recommenderBuilder.buildRecommender(datamodel);

            List<RecommendedItem> recommendations = recommender.recommend(176, 10);

            for (RecommendedItem recommendation : recommendations) {
                System.out.println(recommendation);
            }

            CustomRecommenderEvaluator recommenderEvaluator = new CustomRecommenderEvaluator(recommenderBuilder, datamodel);
            recommenderEvaluator.compute_recommender_RMSE(0.7);
            recommenderEvaluator.compute_recommender_F1score(10, 4, 0.7);

        }catch(Exception e){
            throw e;
        }

    }
}