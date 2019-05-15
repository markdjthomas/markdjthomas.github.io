#' plots.R
#'
#' author: Mark Thomas
#' modified: May 29, 2018

library(dplyr)
library(readr)
library(ggplot2)
library(reshape2)

setwd("~/Dropbox/Research/MammalNet/DCLDE/presentation/media/data")

smooth_func <- function(x, w=0.95) {
    last <- x[1]
    smoothed <- c()
    for (p in x) {
        tmp <- last * w + (1 - w) * p
        smoothed <- c(smoothed, tmp)
        last <- tmp
    }
    return(smoothed)
}

# COLOURS
# orange: #ef8376, blue: #7ad4f9

# Accuracy -----
eval_acc <- read_csv("run_15_eval-tag-accuracy.csv") %>% 
    select(-`Wall time`) %>% rename(eval = Value) %>% 
    mutate(seval = smooth_func(eval))
train_acc <- read_csv("run_15_train-tag-accuracy.csv") %>% 
    select(-`Wall time`) %>% rename(train = Value) %>% 
    mutate(strain = smooth_func(train))
acc <- left_join(eval_acc, train_acc, by = "Step")

ggplot(acc, aes(x = Step)) + 
    geom_line(aes(y = eval), size = .75, alpha = .25, colour = "#7ad4f9") + 
    geom_line(aes(y = seval), size = 1.25, colour = "#7ad4f9") + 
    geom_label(x = 20000, y = 0.550,  label = "validation set", 
               fill = "#7ad4f9", colour = "white", 
               fontface = "bold", size = 7, label.padding = unit(.4, "lines")) + 
    geom_line(aes(y = train), size = .75, alpha = .25, colour = "#ef8376") + 
    geom_line(aes(y = strain), size = 1.25, colour = "#ef8376") + 
    geom_label(x = 10000, y = 0.675, label = "training set", 
               fill = "#ef8376", colour = "white", 
               fontface = "bold", size = 7, label.padding = unit(.4, "lines")) + 
    scale_x_continuous(limits = c(0, 50000)) + 
    labs(x = "training step", y = "accuracy") + 
    theme_classic(base_size = 26)

# Cross-entropy -----
eval_loss <- read_csv("run_15_eval-tag-loss_1.csv") %>%
    select(-`Wall time`) %>% rename(eval = Value) %>% 
    mutate(seval = smooth_func(eval))
train_loss <- read_csv("run_15_train-tag-loss_1.csv") %>%
    select(-`Wall time`) %>% rename(train = Value) %>% 
    mutate(strain = smooth_func(train))
loss <- left_join(eval_loss, train_loss, by = "Step")

ggplot(loss, aes(x = Step)) + 
    geom_line(aes(y = eval), size = .75, alpha = .25, colour = "#7ad4f9") + 
    geom_line(aes(y = seval), size = 1.25, colour = "#7ad4f9") + 
    geom_label(x = 20000, y = 1.275,  label = "validation set",
               fill = "#7ad4f9", colour = "white",
               fontface = "bold", size = 7, label.padding = unit(.4, "lines")) +
    geom_line(aes(y = train), size = .75, alpha = .25, colour = "#ef8376") + 
    geom_line(aes(y = strain), size = 1.25, colour = "#ef8376") + 
    geom_label(x = 10000, y = 0.975, label = "training set",
               fill = "#ef8376", colour = "white",
               fontface = "bold", size = 7, label.padding = unit(.4, "lines")) +
    scale_x_continuous(limits = c(0, 50000)) +
    scale_y_continuous(limits = c(0.5, 2)) + 
    labs(x = "training step", y = "categorical cross-entropy") + 
    theme_classic(base_size = 26)
