
# Run generalized additive models 
# Written by Alexa Mousley

rm(list=ls())

# Load packages
library('tidyverse')
library('mgcv')
library('dplyr')
library('R.matlab')
library('visreg')
library('ggplot2')
library('gratia') 

### Set paths ###
setwd('/set/input/path')     # <<<<<<<<<<<<<<<< Input path for data
output <- '/set/save/path/'  # <<<<<<<<<<<<<<<< Output path for figures

### Load Demographic Data ###
demographics <- read.csv('demographics.csv')

### Load Statistics ###
measures <- readMat('density-controlled_organizational_measures.mat')
# Or uncomment the line below for variable-density
# measures <- readMat('variable-controlled_organizational_measures.mat')
measures <- measures$organizational.measures

### Create dataframes ###
# Column names
col_names <- c('age','sex','dataset','atlas',
               'global_efficiency','path_length','small_worldness','strength','modularity',
               'core_periphery','kcore','score','local_efficiency','clustering','betweenness','subgraph_centrality')
# Dataframe
global_data <- as.data.frame(bind_cols(demographics,measures))
colnames(global_data) <- col_names

# Get sex-stratified index
sex_index <- global_data$sex==1 # 1 = Female

# Sex-stratified dataframes
Fglobal_data <- as.data.frame(bind_cols(demographics[sex_index,],measures[sex_index,]))
colnames(Fglobal_data) <- col_names
Mglobal_data <- as.data.frame(bind_cols(demographics[!sex_index,],measures[!sex_index,]))
colnames(Mglobal_data) <- col_names

##############################################################################################################################
#
# GAMs and plots for Figure 2 (density-controlled), Extended Data Figure 1 (variable-density) 
# or Extended Data Figure 2 (sex-stratified), depending on which data is input into the model. 
# These results are also included in Table 1 (density-controlled) and Extended Data Table 2 (variable-density)
#
#############################################################################################################################

## Modularity GAM ##
modularity_model <- gam(modularity ~ s(age,bs="cr")+sex+dataset+atlas,
                        data=global_data,method='REML')
mod_der <- derivatives(modularity_model)
gam.check(modularity_model)
summary(modularity_model)
mod_appraise <- appraise(modularity_model)

# Sex-stratified
Fmodularity_model <- gam(modularity ~ s(age,bs="cr")+sex+dataset+atlas,
                         data=Fglobal_data,method='REML')
Mmodularity_model <- gam(modularity ~ s(age,bs="cr")+sex+dataset+atlas,
                         data=Mglobal_data,method='REML')

# Create plots
reg_plots <- visreg(modularity_model, gg=TRUE,type="conditional")
M_plots <- visreg(Mmodularity_model,gg=TRUE,type="conditional")
F_plots <- visreg(Fmodularity_model,gg=TRUE,type="conditional")

# Save predicted values
modularity_predicted <- as.data.frame(reg_plots[[1]]$data$y)
Fmodularity_predicted <- as.data.frame(F_plots[[1]]$data$y)
Mmodularity_predicted <- as.data.frame(M_plots[[1]]$data$y)

# Customize plots
sex_modularity_plot<-ggplot()+
  geom_polygon(fill="gray85",aes(x=reg_plots[[1]]$layers[[1]]$data$x,
                                 y=reg_plots[[1]]$layers[[1]]$data$y),alpha=0.7)+
  geom_point(mapping = aes(x = reg_plots[[1]]$data$x, y = reg_plots[[1]]$data$y),color='black',alpha=0.05)+
  geom_line(mapping = aes(x=reg_plots[[1]]$layers[[3]]$data$x, y=reg_plots[[1]]$layers[[3]]$data$y),
            linewidth=2,color='black')+labs(x='Age',y='Modularity')+
  theme_classic()+theme(text=element_text(family="Arial",size=25,color='black'),
                        axis.text = element_text(family = "Arial",size=18))+
  scale_x_continuous(breaks = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90),
                     labels = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90))+
  annotate("text",x=40,y=0.60,label=sprintf('***'),
           size=15) 
sex_modularity_plot

modularity_plot<-ggplot()+
  geom_polygon(fill="gray85",aes(x=reg_plots[[1]]$layers[[1]]$data$x,
                                 y=reg_plots[[1]]$layers[[1]]$data$y))+
  geom_point(mapping = aes(x = reg_plots[[1]]$data$x, y = reg_plots[[1]]$data$y),color='black',alpha=0.05)+
  geom_line(mapping = aes(x=reg_plots[[1]]$layers[[3]]$data$x, y=reg_plots[[1]]$layers[[3]]$data$y),
            linewidth=2,color='red4')+labs(x='',y='')+
  theme_classic()+theme(text=element_text(family="Arial",size=15,color='black'),
                        axis.text = element_text(family = "Arial",size=18))+
  scale_x_continuous(breaks = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90),
                     labels = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90))+
  annotate("text",x=40,y=0.60,label=sprintf('***'),
           size=15) 
modularity_plot

# Find maximum/minimum #
# Access the data within the specific layer
data_line <- reg_plots[[1]]$layers[[3]]$data
# Find the index of the maximum value in the y column
max_y_index <- which.max(data_line$y)
min_y_index <- which.min(data_line$y)
# Find the corresponding age
data_line$x[max_y_index]
data_line$x[min_y_index]


## Core/Periphery GAM ##
coreness_model <- gam(core_periphery ~ s(age,bs="cr")+sex+dataset+atlas,
                      data=global_data,method='REML')
summary(coreness_model)
core_der <- derivatives(coreness_model)
coreness_appraise <- appraise(coreness_model)

# Sex-stratified
Fcoreness_model <- gam(core_periphery ~ s(age,bs="cr")+sex+dataset+atlas,
                       data=Fglobal_data,method='REML')
Mcoreness_model <- gam(core_periphery ~ s(age,bs="cr")+sex+dataset+atlas,
                       data=Mglobal_data,method='REML')

# Create plots
reg_plots <- visreg(coreness_model, gg=TRUE,type="conditional")
M_plots <- visreg(Mcoreness_model,gg=TRUE,type="conditional")
F_plots <- visreg(Fcoreness_model,gg=TRUE,type="conditional")

# Save predicted values
coreness_predicted <- as.data.frame(reg_plots[[1]]$data$y)
Fcoreness_predicted <- as.data.frame(F_plots[[1]]$data$y)
Mcoreness_predicted <- as.data.frame(M_plots[[1]]$data$y)

# Customize plots
sex_coreness_plot <-ggplot()+
  geom_polygon(fill="gray85",aes(x=reg_plots[[1]]$layers[[1]]$data$x,
                                 y=reg_plots[[1]]$layers[[1]]$data$y))+
  geom_point(mapping = aes(x = reg_plots[[1]]$data$x, y = reg_plots[[1]]$data$y),colour='black',alpha=0.05)+
  geom_line(mapping = aes(x=reg_plots[[1]]$layers[[3]]$data$x, y=reg_plots[[1]]$layers[[3]]$data$y),
            linewidth=2,color='black')+ ylim(0.5,0.95)+
  theme_classic()+labs(x='Age',y='Core/Periphery')+
  theme(text=element_text(family="Arial",size=25,color='black'),
        axis.text = element_text(family = "Arial",size=20))+
  annotate("text",x=40,y=0.85,label=sprintf('***'),
           size=15) +
  scale_x_continuous(breaks = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90),
                     labels = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90))
sex_coreness_plot

coreness_plot <-ggplot()+
  geom_polygon(fill="gray85",aes(x=reg_plots[[1]]$layers[[1]]$data$x,
                                 y=reg_plots[[1]]$layers[[1]]$data$y))+
  geom_point(mapping = aes(x = reg_plots[[1]]$data$x, y = reg_plots[[1]]$data$y),colour='black',alpha=0.05)+
  geom_line(mapping = aes(x=reg_plots[[1]]$layers[[3]]$data$x, y=reg_plots[[1]]$layers[[3]]$data$y),
            linewidth=2,color='red4')+ ylim(0.5,0.95)+
  theme_classic()+labs(x='',y='')+
  theme(text=element_text(family="Arial",size=15,color='black'),
        axis.text = element_text(family = "Arial",size=18))+
  annotate("text",x=40,y=0.85,label=sprintf('***'),
           size=15) +
  scale_x_continuous(breaks = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90),
                     labels = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90))
coreness_plot

# Find max/min #
# Access the data within the specific layer
data_line <- reg_plots[[1]]$layers[[3]]$data
# Find the index of the maximum value in the y column
max_y_index <- which.max(data_line$y)
min_y_index <- which.min(data_line$y)
# Find the corresponding age
data_line$x[max_y_index]
data_line$x[min_y_index]

## Global efficiency ##
ge_model <- gam(global_efficiency ~ s(age,bs="cr")+sex+dataset+atlas,
                data=global_data,method='REML')
summary(ge_model)
ge_der <- derivatives(ge_model)
gam.check(ge_model)
ge_appraise <- appraise(ge_model)

# Sex-stratified
Fge_model <- gam(global_efficiency ~ s(age,bs="cr")+sex+dataset+atlas,data=Fglobal_data,method='REML')
Mge_model <- gam(global_efficiency ~ s(age,bs="cr")+sex+dataset+atlas,data=Mglobal_data,method='REML')

# Create plots
reg_plots <- visreg(ge_model, gg=TRUE,type="conditional")
F_plots <- visreg(Fge_model,gg=TRUE,type="conditional")
M_plots <- visreg(Mge_model,gg=TRUE,type="conditional")

# Save predicted values
ge_predicted <- as.data.frame(reg_plots[[1]]$data$y)
Mge_predicted <- as.data.frame(M_plots[[1]]$data$y)
Fge_predicted <- as.data.frame(F_plots[[1]]$data$y)

# Custoize plots
sex_ge_plot<-ggplot()+
  geom_polygon(fill="gray85",aes(x=M_plots[[1]]$layers[[1]]$data$x,
                                 y=M_plots[[1]]$layers[[1]]$data$y),alpha=0.7)+
  geom_point(mapping = aes(x = M_plots[[1]]$data$x, y = M_plots[[1]]$data$y),color='blue',alpha=0.1)+
  geom_line(mapping = aes(x=M_plots[[1]]$layers[[3]]$data$x, y=M_plots[[1]]$layers[[3]]$data$y),
            linewidth=2,color='blue')+
  geom_polygon(fill="gray85",aes(x=F_plots[[1]]$layers[[1]]$data$x,
                                 y=F_plots[[1]]$layers[[1]]$data$y),alpha=0.7)+
  geom_point(mapping = aes(x = F_plots[[1]]$data$x, y = F_plots[[1]]$data$y),color='red',alpha=0.1)+
  geom_line(mapping = aes(x= F_plots[[1]]$layers[[3]]$data$x, y= F_plots[[1]]$layers[[3]]$data$y),
            linewidth=2,color='red')+labs(x='Age',y='Global Efficiency')+
  theme_classic()+theme(text=element_text(family="Arial",size=25,color='black'),
                        axis.text = element_text(family = "Arial",size=20))+
  scale_x_continuous(breaks = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90),
                     labels = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90))+
  annotate("text",x=40,y=0.49,label=sprintf('***'),
           size=15) 
sex_ge_plot

ge_plot<-ggplot()+
  geom_polygon(fill="gray85",aes(x=reg_plots[[1]]$layers[[1]]$data$x,
                                 y=reg_plots[[1]]$layers[[1]]$data$y))+
  geom_point(mapping = aes(x = reg_plots[[1]]$data$x, y = reg_plots[[1]]$data$y),color='black',alpha=0.1)+
  geom_line(mapping = aes(x=reg_plots[[1]]$layers[[3]]$data$x, y=reg_plots[[1]]$layers[[3]]$data$y),
            linewidth=2,color='red4')+labs(x='',y='')+
  theme_classic()+theme(text=element_text(family="Arial",size=15,color='black'),
                        axis.text = element_text(family = "Arial",size=18))+
  scale_x_continuous(breaks = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90),
                     labels = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90))+
  annotate("text",x=40,y=0.49,label=sprintf('***'),
           size=15) 
ge_plot

# Find max/min #
# Access the data within the specific layer
data_line <- reg_plots[[1]]$layers[[3]]$data
# Find the index of the maximum value in the y column
max_y_index <- which.max(data_line$y)
min_y_index <- which.min(data_line$y)
# Find the corresponding age
data_line$x[max_y_index]
data_line$x[min_y_index]

## Characteristic Path Length ##
path_length_model <- gam(path_length ~ s(age,bs="cr")+sex+dataset+atlas,
                         data=global_data,method='REML')
summary(path_length_model)
path_der <- derivatives(path_length_model)
path_appraise <- appraise(path_length_model)

# Sex-stratified
Fpath_length_model <- gam(path_length ~ s(age,bs="cr")+sex+dataset+atlas,
                          data=Fglobal_data,method='REML')
Mpath_length_model <- gam(path_length ~ s(age,bs="cr")+sex+dataset+atlas,
                          data=Mglobal_data,method='REML')

# Create plots
reg_plots <- visreg(path_length_model, gg=TRUE,type="conditional")
F_plots <- visreg(Fpath_length_model,gg=TRUE,type="conditional")
M_plots <- visreg(Mpath_length_model,gg=TRUE,type="conditional")

# Save predicted values
path_length_predicted <- as.data.frame(reg_plots[[1]]$data$y)
Mpath_length_predicted <- as.data.frame(M_plots[[1]]$data$y)
Fpath_length_predicted <- as.data.frame(F_plots[[1]]$data$y)

# Customize plots
sex_path_length_plot<-ggplot()+
  geom_polygon(fill="gray85",aes(x=M_plots[[1]]$layers[[1]]$data$x,
                                 y=M_plots[[1]]$layers[[1]]$data$y),alpha=0.7)+
  geom_point(mapping = aes(x = M_plots[[1]]$data$x, y = M_plots[[1]]$data$y),color='blue',alpha=0.1)+
  geom_line(mapping = aes(x=M_plots[[1]]$layers[[3]]$data$x, y=M_plots[[1]]$layers[[3]]$data$y),
            linewidth=2,color='blue')+
  geom_polygon(fill="gray85",aes(x=F_plots[[1]]$layers[[1]]$data$x,
                                 y=F_plots[[1]]$layers[[1]]$data$y),alpha=0.7)+
  geom_point(mapping = aes(x = F_plots[[1]]$data$x, y = F_plots[[1]]$data$y),color='red',alpha=0.1)+
  geom_line(mapping = aes(x= F_plots[[1]]$layers[[3]]$data$x, y= F_plots[[1]]$layers[[3]]$data$y),
            linewidth=2,color='red')+labs(x='Age',y='Characteristic Path Length')+
  theme_classic()+theme(text=element_text(family="Arial",size=25,color='black'),
                        axis.text = element_text(family = "Arial",size=20))+
  scale_x_continuous(breaks = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90),
                     labels = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90))+
  annotate("text",x=40,y=2.68,label=sprintf('***'),
           size=15) 
sex_path_length_plot

path_length_plot<-ggplot()+
  geom_polygon(fill="gray85",aes(x=reg_plots[[1]]$layers[[1]]$data$x,
                                 y=reg_plots[[1]]$layers[[1]]$data$y))+
  geom_point(mapping = aes(x = reg_plots[[1]]$data$x, y = reg_plots[[1]]$data$y),color='black',alpha=0.1)+
  geom_line(mapping = aes(x=reg_plots[[1]]$layers[[3]]$data$x, y=reg_plots[[1]]$layers[[3]]$data$y),
            linewidth=2,color='red4')+labs(x='',y='')+
  theme_classic()+theme(text=element_text(family="Arial",size=15,color='black'),
                        axis.text = element_text(family = "Arial",size=18))+
  scale_x_continuous(breaks = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90),
                     labels = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90))+
  annotate("text",x=40,y=2.68,label=sprintf('***'),
           size=15) 
path_length_plot

# Find max/min #
# Access the data within the specific layer
data_line <- reg_plots[[1]]$layers[[3]]$data
# Find the index of the maximum value in the y column
max_y_index <- which.max(data_line$y)
min_y_index <- which.min(data_line$y)
# Find the corresponding age
data_line$x[max_y_index]
data_line$x[min_y_index]

## K-Core Count ##
kcore_model <- gam(kcore ~ s(age,bs="cr")+sex+dataset+atlas,
                   data=global_data,method='REML')
summary(kcore_model)
kcore_appraise <- appraise(kcore_model)

# Sex-stratified
Fkcore_model <- gam(kcore ~ s(age,bs="cr")+sex+dataset+atlas,data=Fglobal_data,method='REML')
Mkcore_model <- gam(kcore ~ s(age,bs="cr")+sex+dataset+atlas,data=Mglobal_data,method='REML')

# Create plots
reg_plots <- visreg(kcore_model, gg=TRUE,type="conditional")
F_plots <- visreg(Fkcore_model,gg=TRUE,type="conditional")
M_plots <- visreg(Mkcore_model,gg=TRUE,type="conditional")

# Save predicted values
kcore_predicted <- as.data.frame(reg_plots[[1]]$data$y)
Mkcore_predicted <- as.data.frame(M_plots[[1]]$data$y)
Fkcore_predicted <- as.data.frame(F_plots[[1]]$data$y)

# Customize plots
sex_kcore_plot<-ggplot()+
  geom_polygon(fill="gray85",aes(x=reg_plots[[1]]$layers[[1]]$data$x,
                                 y=reg_plots[[1]]$layers[[1]]$data$y),alpha=0.7)+
  geom_point(mapping = aes(x = reg_plots[[1]]$data$x, y = reg_plots[[1]]$data$y),color='black',alpha=0.05)+
  geom_line(mapping = aes(x=reg_plots[[1]]$layers[[3]]$data$x, y=reg_plots[[1]]$layers[[3]]$data$y),
            linewidth=2,color='black')+labs(x='Age',y='K-core')+
  theme_classic()+theme(text=element_text(family="Arial",size=25,color='black'),
                        axis.text = element_text(family = "Arial",size=20))+
  scale_x_continuous(breaks = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90),
                     labels = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90))
sex_kcore_plot

kcore_plot<-ggplot()+
  geom_polygon(fill="gray85",aes(x=reg_plots[[1]]$layers[[1]]$data$x,
                                 y=reg_plots[[1]]$layers[[1]]$data$y))+
  geom_point(mapping = aes(x = reg_plots[[1]]$data$x, y = reg_plots[[1]]$data$y),color='black',alpha=0.05)+
  geom_line(mapping = aes(x=reg_plots[[1]]$layers[[3]]$data$x, y=reg_plots[[1]]$layers[[3]]$data$y),
            linewidth=2,color='black')+labs(x='',y='')+
  theme_classic()+theme(text=element_text(family="Arial",size=15,color='black'),
                        axis.text = element_text(family = "Arial",size=18))+
  scale_x_continuous(breaks = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90),
                     labels = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90))
kcore_plot

## S-Core Count ##
score_model <- gam(score ~ s(age,bs="cr")+sex+dataset+atlas,
                   data=global_data,method='REML')
summary(score_model)
score_der <- derivatives(score_model)
score_appraise <- appraise(score_model)

# Sex-stratified
Mscore_model <- gam(score ~ s(age,bs="cr")+sex+dataset+atlas,
                    data=Mglobal_data,method='REML')
Fscore_model <- gam(score ~ s(age,bs="cr")+sex+dataset+atlas,
                    data=Fglobal_data,method='REML')

# Create plots
reg_plots <- visreg(score_model, gg=TRUE,type="conditional")
M_plots <- visreg(Mscore_model,gg=TRUE,type="conditional")
F_plots <- visreg(Fscore_model,gg=TRUE,type="conditional")

# Save predicted values
score_predicted <- as.data.frame(reg_plots[[1]]$data$y)
Mscore_predicted <- as.data.frame(M_plots[[1]]$data$y)
Fscore_predicted <- as.data.frame(F_plots[[1]]$data$y)

# Customize plots
sex_score_plot<-ggplot()+
  geom_polygon(fill="gray85",aes(x=reg_plots[[1]]$layers[[1]]$data$x,
                                 y=reg_plots[[1]]$layers[[1]]$data$y),alpha=0.7)+
  geom_point(mapping = aes(x = reg_plots[[1]]$data$x, y = reg_plots[[1]]$data$y),color='black',alpha=0.05)+
  geom_line(mapping = aes(x=reg_plots[[1]]$layers[[3]]$data$x, y=reg_plots[[1]]$layers[[3]]$data$y),
            linewidth=2,color='black')+labs(x='Age',y='S-core')+
  theme_classic()+
  scale_x_continuous(breaks = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90),
                     labels = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90))+
  theme(text=element_text(family="Arial",size=25,color='black'),
        axis.text = element_text(family = "Arial",size=20))+
  annotate("text",x=40,y=75,label=sprintf('***'),
           size=15) 
sex_score_plot

score_plot<-ggplot()+
  geom_polygon(fill="gray85",aes(x=reg_plots[[1]]$layers[[1]]$data$x,
                                 y=reg_plots[[1]]$layers[[1]]$data$y))+
  geom_point(mapping = aes(x = reg_plots[[1]]$data$x, y = reg_plots[[1]]$data$y),color='black',alpha=0.05)+
  geom_line(mapping = aes(x=reg_plots[[1]]$layers[[3]]$data$x, y=reg_plots[[1]]$layers[[3]]$data$y),
            linewidth=2,color='red4')+labs(x='',y='')+
  theme_classic()+
  scale_x_continuous(breaks = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90),
                     labels = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90))+
  theme(text=element_text(family="Arial",size=15,color='black'),
        axis.text = element_text(family = "Arial",size=18))+
  annotate("text",x=40,y=75,label=sprintf('***'),
           size=15) 
score_plot

# Find max/min #
# Access the data within the specific layer
data_line <- reg_plots[[1]]$layers[[3]]$data
# Find the index of the maximum value in the y column
max_y_index <- which.max(data_line$y)
min_y_index <- which.min(data_line$y)
# Find the corresponding age
data_line$x[max_y_index]
data_line$x[min_y_index]

## Small Worldness ##
small_world_model <- gam(small_worldness ~ s(age,bs="cr")+sex+dataset+atlas,
                         data=global_data,method='REML')
summary(small_world_model)
small_world_der <- derivatives(small_world_model)
sw_appraise <- appraise(small_world_model)

# Sex-stratified models
Fsmall_world_model <- gam(small_worldness ~ s(age,bs="cr")+sex+dataset+atlas,
                          data=Fglobal_data,method='REML')
Msmall_world_model <- gam(small_worldness ~ s(age,bs="cr")+sex+dataset+atlas,
                          data=Mglobal_data,method='REML')

# Create plots
reg_plots <- visreg(small_world_model, gg=TRUE,type="conditional")
M_plots <- visreg(Msmall_world_model,gg=TRUE,type="conditional")
F_plots <- visreg(Fsmall_world_model,gg=TRUE,type="conditional")

# Save predicted vlues
small_world_predicted <- as.data.frame(reg_plots[[1]]$data$y)
Fsmall_world_predicted <- as.data.frame(F_plots[[1]]$data$y)
Msmall_world_predicted <- as.data.frame(M_plots[[1]]$data$y)

# Customize plots
sex_small_world_plot<-ggplot()+
  geom_polygon(fill="gray85",aes(x=M_plots[[1]]$layers[[1]]$data$x,
                                 y=M_plots[[1]]$layers[[1]]$data$y),alpha=0.7)+
  geom_point(mapping = aes(x = M_plots[[1]]$data$x, y = M_plots[[1]]$data$y),color='blue',alpha=0.1)+
  geom_line(mapping = aes(x=M_plots[[1]]$layers[[3]]$data$x, y=M_plots[[1]]$layers[[3]]$data$y),
            linewidth=2,color='blue')+
  geom_polygon(fill="gray85",aes(x=F_plots[[1]]$layers[[1]]$data$x,
                                 y=F_plots[[1]]$layers[[1]]$data$y),alpha=0.7)+
  geom_point(mapping = aes(x = F_plots[[1]]$data$x, y = F_plots[[1]]$data$y),color='red',alpha=0.1)+
  geom_line(mapping = aes(x= F_plots[[1]]$layers[[3]]$data$x, y= F_plots[[1]]$layers[[3]]$data$y),
            linewidth=2,color='red')+labs(x='Age',y='Small Worldness')+
  theme_classic()+theme(text=element_text(family="Arial",size=25,color='black'),
                        axis.text = element_text(family = "Arial",size=20))+
  scale_x_continuous(breaks = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90),
                     labels = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90))+
  annotate("text",x=40,y=2.5,label=sprintf('***'),
           size=15) 
sex_small_world_plot

small_world_plot<-ggplot()+
  geom_polygon(fill="gray85",aes(x=reg_plots[[1]]$layers[[1]]$data$x,
                                 y=reg_plots[[1]]$layers[[1]]$data$y))+
  geom_point(mapping = aes(x = reg_plots[[1]]$data$x, y = reg_plots[[1]]$data$y),color='black',alpha=0.1)+
  geom_line(mapping = aes(x=reg_plots[[1]]$layers[[3]]$data$x, y=reg_plots[[1]]$layers[[3]]$data$y),
            linewidth=2,color='red4')+labs(x='',y='')+
  theme_classic()+theme(text=element_text(family="Arial",size=15,color='black'),
                        axis.text = element_text(family = "Arial",size=18))+
  scale_x_continuous(breaks = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90),
                     labels = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90))+
  annotate("text",x=40,y=2.5,label=sprintf('***'),
           size=15) 
small_world_plot

# Find max/min #
# Access the data within the specific layer
data_line <- reg_plots[[1]]$layers[[3]]$data
# Find the index of the maximum value in the y column
max_y_index <- which.max(data_line$y)
min_y_index <- which.min(data_line$y)
# Find the corresponding age
data_line$x[max_y_index]
data_line$x[min_y_index]

## Strength ##
strength_model <- gam(strength ~ s(age,bs="cr")+sex+dataset+atlas,
                      data=global_data,method='REML')
summary(strength_model)
strength_der <- derivatives(strength_model)
strength_appraise <- appraise(strength_model)

# Sex-stratified models
Fstrength_model <- gam(strength ~ s(age,bs="cr")+sex+dataset+atlas,
                       data=Fglobal_data,method='REML')
Mstrength_model <- gam(strength ~ s(age,bs="cr")+sex+dataset+atlas,
                       data=Mglobal_data,method='REML')

# Create plots
reg_plots <- visreg(strength_model, gg=TRUE,type="conditional")
M_plots <- visreg(Mstrength_model,gg=TRUE,type="conditional")
F_plots <- visreg(Fstrength_model,gg=TRUE,type="conditional")

# Save predicted values
strength_predicted <- as.data.frame(reg_plots[[1]]$data$y)
Fstrength_predicted <- as.data.frame(F_plots[[1]]$data$y)
Mstrength_predicted <- as.data.frame(M_plots[[1]]$data$y)

# Customize plots
sex_strength_plot<-ggplot()+
  geom_polygon(fill="gray85",aes(x=reg_plots[[1]]$layers[[1]]$data$x,
                                 y=reg_plots[[1]]$layers[[1]]$data$y),alpha=0.7)+
  geom_point(mapping = aes(x = reg_plots[[1]]$data$x, y = reg_plots[[1]]$data$y),color='black',alpha=0.05)+
  geom_line(mapping = aes(x=reg_plots[[1]]$layers[[3]]$data$x, y=reg_plots[[1]]$layers[[3]]$data$y),
            linewidth=2,color='black')+labs(x='Age',y='Strength')+
  theme_classic()+
  scale_x_continuous(breaks = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90),
                     labels = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90))+
  theme(text=element_text(family="Arial",size=25,color='black'),
        axis.text = element_text(family = "Arial",size=20))+
  annotate("text",x=40,y=1.6,label=sprintf('***'),
           size=15) 
sex_strength_plot

strength_plot<-ggplot()+
  geom_polygon(fill="gray85",aes(x=reg_plots[[1]]$layers[[1]]$data$x,
                                 y=reg_plots[[1]]$layers[[1]]$data$y))+
  geom_point(mapping = aes(x = reg_plots[[1]]$data$x, y = reg_plots[[1]]$data$y),color='black',alpha=0.05)+
  geom_line(mapping = aes(x=reg_plots[[1]]$layers[[3]]$data$x, y=reg_plots[[1]]$layers[[3]]$data$y),
            linewidth=2,color='red4')+labs(x='',y='')+
  theme_classic()+
  scale_x_continuous(breaks = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90),
                     labels = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90))+
  theme(text=element_text(family="Arial",size=15,color='black'),
        axis.text = element_text(family = "Arial",size=18))+
  annotate("text",x=40,y=1.6,label=sprintf('***'),
           size=15) 
strength_plot

# Find max/min #
# Access the data within the specific layer
data_line <- reg_plots[[1]]$layers[[3]]$data
# Find the index of the maximum value in the y column
max_y_index <- which.max(data_line$y)
min_y_index <- which.min(data_line$y)
# Find the corresponding age
data_line$x[max_y_index]
data_line$x[min_y_index]

## Mean Local Efficiency ##
mean_local_efficiency_model <- gam(local_efficiency ~ s(age,bs="cr")+sex+dataset+atlas,
                                   data=global_data,method='REML')
summary(mean_local_efficiency_model)
le_der <- derivatives(mean_local_efficiency_model)
le_appraise <- appraise(mean_local_efficiency_model)

# Sex-stratified models
Fmean_local_efficiency_model <- gam(local_efficiency ~ s(age,bs="cr")+sex+dataset+atlas,
                                    data=Fglobal_data,method='REML')
Mmean_local_efficiency_model <- gam(local_efficiency ~ s(age,bs="cr")+sex+dataset+atlas,
                                    data=Mglobal_data,method='REML')

# Create plots
reg_plots <- visreg(mean_local_efficiency_model, gg=TRUE,type="conditional")
M_plots <- visreg(Mmean_local_efficiency_model,gg=TRUE,type="conditional")
F_plots <- visreg(Fmean_local_efficiency_model,gg=TRUE,type="conditional")

# Save predicted values
local_eff_predicted <- as.data.frame(reg_plots[[1]]$data$y)
Flocal_eff_predicted <- as.data.frame(F_plots[[1]]$data$y)
Mlocal_eff_predicted <- as.data.frame(M_plots[[1]]$data$y)

# Customize plots
sex_mean_local_efficiency_plot <-ggplot()+
  geom_polygon(fill="gray85",aes(x=M_plots[[1]]$layers[[1]]$data$x,
                                 y=M_plots[[1]]$layers[[1]]$data$y),alpha=0.7)+
  geom_point(mapping = aes(x = M_plots[[1]]$data$x, y = M_plots[[1]]$data$y),color='blue',alpha=0.1)+
  geom_line(mapping = aes(x=M_plots[[1]]$layers[[3]]$data$x, y=M_plots[[1]]$layers[[3]]$data$y),
            linewidth=2,color='blue')+
  geom_polygon(fill="gray85",aes(x=F_plots[[1]]$layers[[1]]$data$x,
                                 y=F_plots[[1]]$layers[[1]]$data$y),alpha=0.7)+
  geom_point(mapping = aes(x = F_plots[[1]]$data$x, y = F_plots[[1]]$data$y),color='red',alpha=0.1)+
  geom_line(mapping = aes(x= F_plots[[1]]$layers[[3]]$data$x, y= F_plots[[1]]$layers[[3]]$data$y),
            linewidth=2,color='red')+labs(x='Age',y='Local Efficiency')+
  theme_classic()+theme(text=element_text(family="Arial",size=25,color='black'),
                        axis.text = element_text(family = "Arial",size=20))+
  scale_x_continuous(breaks = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90),
                     labels = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90))+
  annotate("text",x=40,y=0.1,label=sprintf('***'),
           size=15) 
sex_mean_local_efficiency_plot

mean_local_efficiency_plot <-ggplot()+
  geom_polygon(fill="gray85",aes(x=reg_plots[[1]]$layers[[1]]$data$x,
                                 y=reg_plots[[1]]$layers[[1]]$data$y))+
  geom_point(mapping = aes(x = reg_plots[[1]]$data$x, y = reg_plots[[1]]$data$y),color='black',alpha=0.1)+
  geom_line(mapping = aes(x=reg_plots[[1]]$layers[[3]]$data$x, y=reg_plots[[1]]$layers[[3]]$data$y),
            linewidth=2,color='red4')+labs(x='',y='')+
  theme_classic()+theme(text=element_text(family="Arial",size=15,color='black'),
                        axis.text = element_text(family = "Arial",size=18))+
  scale_x_continuous(breaks = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90),
                     labels = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90))+
  annotate("text",x=40,y=0.1,label=sprintf('***'),
           size=15) 
mean_local_efficiency_plot

# Find max/min #
# Access the data within the specific layer
data_line <- reg_plots[[1]]$layers[[3]]$data
# Find the index of the maximum value in the y column
max_y_index <- which.max(data_line$y)
min_y_index <- which.min(data_line$y)
# Find the corresponding age
data_line$x[max_y_index]
data_line$x[min_y_index]

## Mean Betweenness ##
mean_betweenness_model <- gam(betweenness ~ s(age,bs="cr")+sex+dataset+atlas,
                              data=global_data,method='REML')
summary(mean_betweenness_model)
between_der <- derivatives(mean_betweenness_model)
between_appraise <- appraise(mean_betweenness_model)

# Sex-stratified models
Fbetweenness_model <- gam(betweenness ~ s(age,bs="cr")+sex+dataset+atlas,
                          data=Fglobal_data,method='REML')
Mbetweenness_model <- gam(betweenness ~ s(age,bs="cr")+sex+dataset+atlas,
                          data=Mglobal_data,method='REML')

# Create plots
F_plots <- visreg(Fbetweenness_model,gg=TRUE,type="conditional")
M_plots <- visreg(Mbetweenness_model,gg=TRUE,type="conditional")
reg_plots <- visreg(mean_betweenness_model, gg=TRUE,type="conditional")

# Save predicted values
betweenness_predicted <- as.data.frame(reg_plots[[1]]$data$y)
Mbetweenness_predicted <- as.data.frame(M_plots[[1]]$data$y)
Fbetweenness_predicted <- as.data.frame(F_plots[[1]]$data$y)

# Customize plots
sex_mean_betweenness_plot<-ggplot()+
  geom_polygon(fill="gray85",aes(x=M_plots[[1]]$layers[[1]]$data$x,
                                 y=M_plots[[1]]$layers[[1]]$data$y),alpha=0.7)+
  geom_point(mapping = aes(x = M_plots[[1]]$data$x, y = M_plots[[1]]$data$y),color='blue',alpha=0.1)+
  geom_line(mapping = aes(x=M_plots[[1]]$layers[[3]]$data$x, y=M_plots[[1]]$layers[[3]]$data$y),
            linewidth=2,color='blue')+
  geom_polygon(fill="gray85",aes(x=F_plots[[1]]$layers[[1]]$data$x,
                                 y=F_plots[[1]]$layers[[1]]$data$y),alpha=0.7)+
  geom_point(mapping = aes(x = F_plots[[1]]$data$x, y = F_plots[[1]]$data$y),color='red',alpha=0.1)+
  geom_line(mapping = aes(x= F_plots[[1]]$layers[[3]]$data$x, y= F_plots[[1]]$layers[[3]]$data$y),
            linewidth=2,color='red')+labs(x='Age',y='Betweenness Centrality')+
  theme_classic()+theme(text=element_text(family="Arial",size=25,color='black'),
                        axis.text = element_text(family = "Arial",size=20))+
  scale_x_continuous(breaks = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90),
                     labels = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90))+
  annotate("text",x=40,y=270,label=sprintf('***'),
           size=15) 
sex_mean_betweenness_plot

mean_betweenness_plot<-ggplot()+
  geom_polygon(fill="gray85",aes(x=reg_plots[[1]]$layers[[1]]$data$x,
                                 y=reg_plots[[1]]$layers[[1]]$data$y))+
  geom_point(mapping = aes(x = reg_plots[[1]]$data$x, y = reg_plots[[1]]$data$y),color='black',alpha=0.1)+
  geom_line(mapping = aes(x=reg_plots[[1]]$layers[[3]]$data$x, y=reg_plots[[1]]$layers[[3]]$data$y),
            linewidth=2,color='red4')+labs(x='',y='')+
  theme_classic()+theme(text=element_text(family="Arial",size=15,color='black'),
                        axis.text = element_text(family = "Arial",size=18))+
  scale_x_continuous(breaks = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90),
                     labels = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90))+
  annotate("text",x=40,y=270,label=sprintf('***'),
           size=15) 
mean_betweenness_plot

# Find max/min #
# Access the data within the specific layer
data_line <- reg_plots[[1]]$layers[[3]]$data
# Find the index of the maximum value in the y column
max_y_index <- which.max(data_line$y)
min_y_index <- which.min(data_line$y)
# Find the corresponding age
data_line$x[max_y_index]
data_line$x[min_y_index]

## Mean Clustering ##
mean_clustering_model <- gam(clustering ~ s(age,bs="cr")+sex+dataset+atlas,
                             data=global_data,method='REML')
summary(mean_clustering_model)
clustering_der <- derivatives(mean_clustering_model)
cluster_appraise <- appraise(mean_clustering_model)

# Sex-stratified models
Fmean_clustering_model <- gam(clustering ~ s(age,bs="cr")+sex+dataset+atlas,
                              data=Fglobal_data,method='REML')
Mmean_clustering_model <- gam(clustering ~ s(age,bs="cr")+sex+dataset+atlas,
                              data=Mglobal_data,method='REML')

# Create plots
reg_plots <- visreg(mean_clustering_model, gg=TRUE,type="conditional")
M_plots <- visreg(Mmean_clustering_model,gg=TRUE,type="conditional")
F_plots <- visreg(Fmean_clustering_model,gg=TRUE,type="conditional")

# Save predicted values
clustering_predicted <- as.data.frame(reg_plots[[1]]$data$y)
Fclustering_predicted <- as.data.frame(F_plots[[1]]$data$y)
Mclustering_predicted <- as.data.frame(M_plots[[1]]$data$y)

# Customize plots
sex_mean_clustering_plot<-ggplot()+
  geom_polygon(fill="gray85",aes(x=M_plots[[1]]$layers[[1]]$data$x,
                                 y=M_plots[[1]]$layers[[1]]$data$y),alpha=0.7)+
  geom_point(mapping = aes(x = M_plots[[1]]$data$x, y = M_plots[[1]]$data$y),color='blue',alpha=0.1)+
  geom_line(mapping = aes(x=M_plots[[1]]$layers[[3]]$data$x, y=M_plots[[1]]$layers[[3]]$data$y),
            linewidth=2,color='blue')+
  geom_polygon(fill="gray85",aes(x=F_plots[[1]]$layers[[1]]$data$x,
                                 y=F_plots[[1]]$layers[[1]]$data$y),alpha=0.7)+
  geom_point(mapping = aes(x = F_plots[[1]]$data$x, y = F_plots[[1]]$data$y),color='red',alpha=0.1)+
  geom_line(mapping = aes(x= F_plots[[1]]$layers[[3]]$data$x, y= F_plots[[1]]$layers[[3]]$data$y),
            linewidth=2,color='red')+labs(x='Age',y='Clustering Coefficient')+
  theme_classic()+theme(text=element_text(family="Arial",size=25,color='black'),
                        axis.text = element_text(family = "Arial",size=20))+
  scale_x_continuous(breaks = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90),
                     labels = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90))+
  annotate("text",x=40,y=0.06,label=sprintf('***'),
           size=15)
sex_mean_clustering_plot

mean_clustering_plot<-ggplot()+
  geom_polygon(fill="gray85",aes(x=reg_plots[[1]]$layers[[1]]$data$x,
                                 y=reg_plots[[1]]$layers[[1]]$data$y))+
  geom_point(mapping = aes(x = reg_plots[[1]]$data$x, y = reg_plots[[1]]$data$y),color='black',alpha=0.1)+
  geom_line(mapping = aes(x=reg_plots[[1]]$layers[[3]]$data$x, y=reg_plots[[1]]$layers[[3]]$data$y),
            linewidth=2,color='red4')+labs(x='',y='')+
  theme_classic()+theme(text=element_text(family="Arial",size=15,color='black'),
                        axis.text = element_text(family = "Arial",size=18))+
  scale_x_continuous(breaks = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90),
                     labels = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90))+
  annotate("text",x=40,y=0.0555,label=sprintf('***'),
           size=15)
mean_clustering_plot

# Find max/min #
# Access the data within the specific layer
data_line <- reg_plots[[1]]$layers[[3]]$data
# Find the index of the maximum value in the y column
max_y_index <- which.max(data_line$y)
min_y_index <- which.min(data_line$y)
# Find the corresponding age
data_line$x[max_y_index]
data_line$x[min_y_index]

## Mean Subgraph Centrality ##
mean_subgraph_centrality_model <- gam(subgraph_centrality ~ s(age,bs="cr")+sex+dataset+atlas,
                                      data=global_data,method='REML')
summary(mean_subgraph_centrality_model)
subgraph_der <- derivatives(mean_subgraph_centrality_model)
subgraph_appraise <- appraise(mean_subgraph_centrality_model)

# Sex-stratified models
Fmean_subgraph_centrality_model <- gam(subgraph_centrality ~ s(age,bs="cr")+sex+dataset+atlas,
                                       data=Fglobal_data,method='REML')
Mmean_subgraph_centrality_model <- gam(subgraph_centrality ~ s(age,bs="cr")+sex+dataset+atlas,
                                       data=Mglobal_data,method='REML')
# Create plots
F_plots <- visreg(Fmean_subgraph_centrality_model,gg=TRUE,type="conditional")
M_plots <- visreg(Mmean_subgraph_centrality_model,gg=TRUE,type="conditional")
reg_plots <- visreg(mean_subgraph_centrality_model, gg=TRUE,type="conditional")

# Save predicted values
subgraph_centrality_predicted <- as.data.frame(reg_plots[[1]]$data$y)
Msubgraph_centrality_predicted <- as.data.frame(M_plots[[1]]$data$y)
Fsubgraph_centrality_predicted <- as.data.frame(F_plots[[1]]$data$y)

# Customize plots
sex_mean_subgraph_centrality_plot<-ggplot()+
  geom_polygon(fill="gray85",aes(x=M_plots[[1]]$layers[[1]]$data$x,
                                 y=M_plots[[1]]$layers[[1]]$data$y),alpha=0.5)+
  geom_point(mapping = aes(x = M_plots[[1]]$data$x, y = M_plots[[1]]$data$y),color='blue',alpha=0.1)+
  geom_line(mapping = aes(x=M_plots[[1]]$layers[[3]]$data$x, y=M_plots[[1]]$layers[[3]]$data$y),
            linewidth=2,color='blue')+
  geom_polygon(fill="gray85",aes(x=F_plots[[1]]$layers[[1]]$data$x,
                                 y=F_plots[[1]]$layers[[1]]$data$y),alpha=0.5)+
  geom_point(mapping = aes(x = F_plots[[1]]$data$x, y = F_plots[[1]]$data$y),color='red',alpha=0.1)+
  geom_line(mapping = aes(x= F_plots[[1]]$layers[[3]]$data$x, y= F_plots[[1]]$layers[[3]]$data$y),
            linewidth=2,color='red')+labs(x='Age',y='Subgraph Centrality')+
  theme_classic()+theme(text=element_text(family="Arial",size=25,color='black'),
                        axis.text = element_text(family = "Arial",size=20))+
  scale_x_continuous(breaks = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90),
                     labels = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90))+
  annotate("text",x=40,y=17000,label=sprintf('***'),
           size=15)
sex_mean_subgraph_centrality_plot

mean_subgraph_centrality_plot<-ggplot()+
  geom_polygon(fill="gray85",aes(x=reg_plots[[1]]$layers[[1]]$data$x,
                                 y=reg_plots[[1]]$layers[[1]]$data$y))+
  geom_point(mapping = aes(x = reg_plots[[1]]$data$x, y = reg_plots[[1]]$data$y),color='black',alpha=0.1)+
  geom_line(mapping = aes(x=reg_plots[[1]]$layers[[3]]$data$x, y=reg_plots[[1]]$layers[[3]]$data$y),
            linewidth=2,color='red4')+labs(x='',y='')+
  theme_classic()+theme(text=element_text(family="Arial",size=15,color='black'),
                        axis.text = element_text(family = "Arial",size=18))+
  scale_x_continuous(breaks = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90),
                     labels = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90))+
  annotate("text",x=40,y=17000,label=sprintf('***'),
           size=15)
mean_subgraph_centrality_plot

# Find max/min #
# Access the data within the specific layer
data_line <- reg_plots[[1]]$layers[[3]]$data
# Find the index of the maximum value in the y column
max_y_index <- which.max(data_line$y)
min_y_index <- which.min(data_line$y)
# Find the corresponding age
data_line$x[max_y_index]
data_line$x[min_y_index]


#### Save data for UMAPS ####

umap_input_data <- bind_cols(global_data$age,
                                      ge_predicted,path_length_predicted,small_world_predicted,strength_predicted,
                                      modularity_predicted,coreness_predicted,score_predicted,local_eff_predicted,
                                      clustering_predicted,betweenness_predicted,subgraph_centrality_predicted)
colnames(umap_input_data) <- c('Age','Global Efficiency', 'Characteristic Path Length', 'Small-Worldness','Strength',
                                        'Modularity', 'Core/Periphery', 'S-Core', 'Local Efficiency', 
                                        'Clustering Coefficient', 'Betweenness Centrality', 'Subgraph Centrality')
female_predicted_data <- bind_cols(Fglobal_data$age,
                                   Fge_predicted,Fpath_length_predicted,Fsmall_world_predicted,Fstrength_predicted,
                                   Fmodularity_predicted,Fcoreness_predicted,Fscore_predicted,Flocal_eff_predicted,
                                   Fclustering_predicted,Fbetweenness_predicted,Fsubgraph_centrality_predicted)
colnames(female_predicted_data) <- c('Age','Global Efficiency', 'Characteristic Path Length', 'Small-Worldness','Strength',
                                     'Modularity', 'Core/Periphery', 'S-Core', 'Local Efficiency', 
                                     'Clustering Coefficient', 'Betweenness Centrality', 'Subgraph Centrality')
male_predicted_data <- bind_cols(Mglobal_data$age,
                                 Mge_predicted,Mpath_length_predicted,Msmall_world_predicted,Mstrength_predicted,
                                 Mmodularity_predicted,Mcoreness_predicted,Mscore_predicted,Mlocal_eff_predicted,
                                 Mclustering_predicted,Mbetweenness_predicted,Msubgraph_centrality_predicted)
colnames(male_predicted_data) <- c('Age','Global Efficiency', 'Characteristic Path Length', 'Small-Worldness','Strength',
                                   'Modularity', 'Core/Periphery', 'S-Core', 'Local Efficiency', 
                                   'Clustering Coefficient', 'Betweenness Centrality', 'Subgraph Centrality')
writeMat("/SET/PATH/umap_input_data.mat",mat=umap_input_data)


