
<H1> Title: Gene expression based inference of cancer drug sensitivity </H1>

<H3> Precily, Deep neural network based framework for prediction of drug response in both in vivo and in vitro settings.</H3>

![Workflow](Workflow.png)

This resource provides code to reproduce key results in the manuscript.
Getting started

<H3>Download Github repository </H3>

   git clone https://github.com/SmritiChawla/Precily.git

<H3> Requirements </H3>

   * keras 2.8.0 
   * keras-tuner 1.1.0
   * caret(v6.0.90) 
   * glmnet(v4.1.3) 
   * ranger(v0.13.1) 
   * GSVA(v1.40.1)
   * h2o(v3.36.0.4)
   * PubChemPy(v1.0.4)
   * SMILESVec
   * EDASeq(v2.26.1)
   * impute(v1.66.0)
   * ggpubr(v0.4.0)
   * ggplot2(v3.3.5)
   * pheatmap(v1.0.12)
   * parsnip(v0.2.1)
   * ggridges(v0.5.3)
   
<H3>Note</H3>

* Data folder contains a zipped file used for training CCLE/GDSC and CCLE/CTRPv2 models. The CCLE GSVA scores are also included in this folder. 
* Data folder also contains pathway scores computed using GSVA for Prostate cancer datasets used for evaluation of Precily. For reproducibility, respective datasets are also provided in each figure directory.

* Use R script EnvSet.R provided in the directory EnvironmentSetup to set up an environment in R for loading python trained deep neural network models.

* Run individual codes from the figure wise directories for reproducing manuscript results.

* We have provided pre-trained CCLE/GDSC models for drug response prediction. DrugsPred.R is the main function used for making predictions and takes the following inputs:
   <br>1. Pathway enrichment scores/GSVA scores
   <br>2. Metadata file. This file contains drugs and cell line names, cancer types and drug descriptors
   <br>3. Cancer Type. Type of cancer to be used for the input test dataset. Cancer types are encoded in form of TCGA abbreviations. 
      
 <b>Example code:</b>
 
 ```Predictions = drugPred(enrichment.scores,metadata,"BRCA")```
 
 The output file is a list of drug response predictions for the individual samples present in the test set.
 


<H3> Description </H3>

   * Fig 1: This folder contains codes for evaluating the CCLE/GDSC data trained model and includes the following subdirectories: 

     Fig 1c. Codes for reproducing different approaches used for benchmarking Precily. Individual codes are provided to run the respective methods. Also, codes to            assess the performance of individual methods are provided based on pre-trained models. For Random Forest, pre-trained pathway and gene based models are provided        in the link [https://drive.google.com/drive/folders/1BbSNS_DXSaLgXt8MVeoySdr0uB-81xKJ?usp=sharing]. 

     Fig 1d. CCLE/GDSC2 data trained models and independent test dataset used to evaluate Precily based deep neural network model. 

     Fig 1e. CCLE/CTRPv2 data trained models and independent test dataset used to evaluate Precily based deep neural network model.


   * Fig 2: This folder contains codes used for evaluating CCLE/GDSC data trained model on scRNA-seq datasets and includes the following subdirectories:

     Fig 2a. This folder contains CCLE/GDSC dataset trained models, processed Kinker,   G. S. et al. scRNA-seq dataset and ground truth labels for evaluation of         Precily.
    
     Fig 2b. This folder contains code for assessing the efficiency of our model on Lee et al. scRNA-seq profiles of MDA-MB-231 breast cancer cells. 


* Fig 3: This directory contains codes for evaluating Precily on the prostate cancer cell line datasets. The GSVA scores for untreated prostate cancer cell lines and treated LNCaP cell lines are provided for drug response prediction.
      
  Fg 3a & b. Evaluation of Precily using Prostate cancer (PCa) baseline cell lines. This folder contains CCLE/GDSC2 models retrained after removing the concerned cell lines present in PCa cell line independent test set and GSVA scores. 
   
  Fig 3c.  This folder contains CCLE/GDSC pre-trained models to assess the performance of Precily on LNCaP cell lines and compare it with groud truth from GDSC database.
   
  Fig 3d. This folder contains pre-trained CCLE/GDSC models and enrichment scores of LNCaP cell lines under different treatment conditions for making predictions.
   
  Fig 3e. This folder contains enrichment scores of LNCaP cell lines under different treatment conditions to investigate the enrichment of proliferation related pathways.
   
  Fig 3f. This folder contains pre-trained CCLE/GDSC models and enrichment scores of LNCaP cell lines under different treatment conditions for analysis of predictions of DNA replication pathway related drug cisplatin.
   
  Fig 3g. The folder contains CCLE/GDSC pre-trained models and file containing SMILES for Orlistat and Metformin drugs.


* Fig 4: This directory contains codes for reproducing results for LNCaP derived xenografts datasets. We have included predictions for 155 drugs for 54 samples and GSVA scores.
   
  Fig 4b. CCLE/GDSC pre-trained models for making predictions on PCa xenograft data. This directory also contains pre-computed predictions used for downstream analysis.  Our xenograft dataset clustered into 3 groups based on the predictions.
   
  Fig 4c. This folder contains code to visualize distribution of predictions across 3 clusters.
   
  Fig 4d. This folder contains pathway enrichment scores of PCa xenograft dataset to visualize the distribution of proliferation related pathways across 3 clusters.
   
  Fig 4e. This directory contains pre-computed predictions on PCa xenograft dataset for visualization of overall predictions across different tumor types.
   
  Fig 4f. This folder contains pathway enrichment scores of PCa xenograft dataset to visualize the distribution of proliferation related pathways across tumor types.
   
  Fig 4g. This directory contains pre-computed predictions on PCa xenograft dataset for analyzing predictions of EGFR related inhibitors across tumor types.
   
  Fig 4h. This directory contains code and SMILES to predict drug response for three drugs (Apalutamide, Enzalutamide and Bicalutamide). These three drugs are not part of our training data.

 * Fig 5. This directory contains codes for evaluating model trained on TCGA patient RNA-seq bulk profiles.

   Fig 5a. This folder contains script and data used for training AutoML models.

   Fig 5b. This folder contains predictions on the TCGA test dataset using the best AutoML model and code for computing survival on these predictions.

   Fig 5d-f. This folder contains codes for evaluating our model using the external Wagle, Nikhil, et al. dataset.
   
* Supplementary directory contains codes for reproducing supplementary figures and some additional codes used for analyses.
