
####################################################################################################
# Vignettes for the brms package
# Date (Y/M/D):  2021/1/28
# Author: Allen Baumgardner-Zuzik
####################################################################################################

# Load packages
library(tidyverse)
library(brms)

#####================ Vignette: Define Custom Response Distributions with brms ================#####

### Introduction ###
# The brms package comes with a lot of built-in response distributions – usually called families in 
# R – to specify among others linear, count data, survival, response times, or ordinal models (see 
# help(brmsfamily) for an overview). Despite supporting over two dozen families, there is still a 
# long list of distributions, which are not natively supported. The present vignette will explain 
# how to specify such custom families in brms. By doing that, users can benefit from the modeling 
# flexibility and post-processing options of brms even when using self-defined response 
# distributions.

### A Case Study ###
# As a case study, we will use the cbpp data of the lme4 package, which describes the development of
# the CBPP disease of cattle in Africa. The data set contains four variables: period (the time 
# period), herd (a factor identifying the cattle herd), incidence (number of new disease cases for a
# given herd and time period), as well as size (the herd size at the beginning of a given time 
# period).

data("cbpp", package = "lme4")
head(cbpp)

# In a first step, we will be predicting incidence using a simple binomial model, which will serve 
# as our baseline model. For observed number of events y (incidence in our case) and total number of
# trials T (size), the probability mass function of the binomial distribution where p is the event 
# probability. In the classical binomial model, we will directly predict p on the logit-scale, which
# means that for each observation i we compute the success probability pi, where ηi is the linear 
# predictor term of observation i (see vignette("brms_overview") for more details on linear 
# predictors in brms). Predicting incidence by period and a varying intercept of herd is straight 
# forward in brms:

fit1 <- brm(incidence | trials(size) ~ period + (1|herd),
           data = cbpp, family = binomial())

# In the summary output, we see that the incidence probability varies substantially over herds, but 
# reduces over the course of the time as indicated by the negative coefficients of period.

summary(fit1)

# A drawback of the binomial model is that – after taking into account the linear predictor – its 
# variance is fixed to Var(yi) = Tipi(1 − pi). All variance exceeding this value cannot be not taken 
# into account by the model. There are multiple ways of dealing with this so called overdispersion 
# and the solution described below will serve as an illustrative example of how to define custom 
# families in brms.


