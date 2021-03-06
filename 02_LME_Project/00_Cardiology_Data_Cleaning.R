##############################################################################################################
# Initial Data Cleaning
# Script author: David Chen
# Script maintainer: David Chen
# Date: 03/10/2018
# Notes:
##############################################################################################################

rm(list=ls())
library(plyr); library(dplyr)
library(gdata)
library(lubridate)
library(WriteXLS)

## Data loading:
path <- easycsv::choose_dir();
setwd(path); 
patientRec <- read.xls("FilterPerf_legs030118.xlsx", stringsAsFactors=F);
patientRec <- patientRec[1:1520, 1:79];
patientRec[patientRec==""] <- NA;

## Go through each parameter and code in unique identifies:
## a: Filter ID:
patientRec$filter_ID <- paste(patientRec$number, patientRec$DateProc, sep="_");

## b: Limb of filter:
patientRec$limb_ID <- paste(patientRec$filter_ID, patientRec$strt, sep="_");

## c: Eval study ID:
patientRec$evalStudy_ID <- paste(patientRec$limb_ID, patientRec$dCT, sep="_");
sum(duplicated(patientRec$evalStudy_ID))

## Enforce numeric type:
patientRec$E1 <- as.numeric(patientRec$E1);
patientRec$N1 <- as.numeric(patientRec$N1);
patientRec$W1 <- as.numeric(patientRec$W1);
patientRec$S1 <- as.numeric(patientRec$S1);

## Re-code in covariates:
patientRec$Cancer <- patientRec$hyper == 2;
patientRec$Thrombosis <- patientRec$newIVCocl == 1;
patientRec$Anticoagulation <- patientRec$ac == 1;
patientRec$VTE <- patientRec$indic == 1;
patientRec$Femoral_access <- patientRec$access %in% c(2,3); 
patientRec$initial_diameter <- as.numeric(patientRec$dIVC);

## Define time: **Factor needed & year Y need to be capitalized!**
patientRec$DateProc <- as.Date(factor(patientRec$DateProc), "%m/%d/%Y");
patientRec$DOB <- as.Date(factor(patientRec$DOB), "%m/%d/%Y");
patientRec$Age <- as.numeric((patientRec$DateProc - patientRec$DOB) / 365);

## Standardize scan date:
patientRec$Scan_date <- as.factor(parse_date_time(
  x = patientRec$dCT,
  orders = c("d m y", "d B Y", "m/d/y")
));

## Export:
## Both write.csv & write.table seem to have error:
rownames(patientRec) <- NULL;
WriteXLS(patientRec, ExcelFileName="FilterPerf_legs030118_cleaned.xls")
## Open this file in Excel and resave as CSV.
