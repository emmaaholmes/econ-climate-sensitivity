# FILE TO GENERATE FIGURE 3

source("reduced_model/logistic_prcc_reduced.R",echo=TRUE)
## table_1
## prcc_res1, logistic_res1
source("full_model/logistic_and_prcc.R",echo=TRUE)
## res 2 (w/o damages & policy)
## prcc_res2, logistic_res2
## res 3 (w/ damages and policy)
## prcc_res3, logistic_res3


library(tidyverse); theme_set(theme_bw())
get_prcc <- function(i) {
    x <- get(paste0("prcc_res",i))
    ret <- (x$PRCC
        %>% rownames_to_column("param")
        %>% as_tibble()
        %>% select(param,est=original, lwr="min. c.i.", upr="max. c.i.")
        %>% mutate(across(param,~gsub("good\\.","",.)))
    )
    return(ret)
}
get_logist <- function(i) {
    x <- get(paste0("logistic_res",i))
    ret <- (broom::tidy(x,conf.int=TRUE)
        %>% select(param=term,est=estimate,lwr=conf.low,upr=conf.high)
        %>% filter(param!="(Intercept)")
    )
    return(ret)
}

tnms <- c("without climate","without damages \nand policy","with damages \nand policy")
L <- map(1:3, ~bind_rows(list(PRCC=get_prcc(.),logistic=get_logist(.)), .id="type"))
names(L) <- tnms
L2 <- (bind_rows(L,.id="model"))

# set the factor levels by hands:
L2 <- mutate(L2,across(param, ~factor(.,levels=c("ECS", "C_UP", "alpha", "gamma", "eta", "markup"))),
             across(model, ~factor(.,levels=c("without climate", "without damages \nand policy", "with damages \nand policy")))) %>%
    drop_na(param)


gg0 <- (ggplot(L2,
               aes(est, param, colour = model, xmin=lwr, xmax=upr)) +
            geom_pointrange(fatten=2, size=0.5) +
            facet_grid(model~type ,scale="free", space="free_y",) +
            geom_vline(xintercept=0,lty=2) +
            labs(x="",y="") +
            scale_y_discrete(labels = c('eta' = expression(eta),
                                        'markup' = expression(xi),
                                        'gamma' = expression(gamma),
                                        'alpha' = expression(alpha),
                                        'ECS' = "S",
                                        'C_UP' = expression(C^UP))) +
            scale_color_brewer(palette = "Set1") +
            theme(panel.spacing=grid::unit(0,"lines"),
                  strip.text.y.right = element_text(angle = 0),
                  legend.position = "none")
)

# ggsave("dotwhisker.pdf",height=4,width=8)

# FOR TIKZ

# tnms <- c("Economic model \nwithout climate",
#           "Full model \nwithout damages \nor policy",
#           "Full model \nwith damages \nand policy")
# L <- map(1:3, ~bind_rows(list(PRCC=get_prcc(.),logistic=get_logist(.)), .id="type"))
# names(L) <- tnms
# L2 <- (bind_rows(L,.id="model"))
# 
# L2 <- mutate(L2,across(param, ~factor(.,levels=c("ECS", "C_UP", "alpha", "gamma", "eta", "markup"))),
#              across(model, ~factor(.,levels=c("Economic model \nwithout climate",
#                                               "Full model \nwithout damages \nor policy",
#                                               "Full model \nwith damages \nand policy")))) %>%
#     drop_na(param) %>% mutate(type = ifelse(type == "logistic","Logistic Regression Coefficients",
#                                             "Partial Rank Correlation Coefficients"))
# 
# library(tikzDevice)
# options(tz="TO")
# tikz(file = "dotwhisker.tex", width = 6, height = 3)
# gg0 <- (ggplot(L2,
#                aes(est, param, colour = model, xmin=lwr, xmax=upr)) +
#             geom_pointrange(fatten=2, size=0.5) +
#             facet_grid(model~type ,scale="free", space="free_y",) +
#             geom_vline(xintercept=0,lty=2) +
#             labs(x="",y="") +
#             scale_y_discrete(labels = c('eta' = '$\\bar \\eta$',
#                                         'markup' = '$\\bar \\xi$',
#                                         'gamma' = '$\\bar \\gamma$',
#                                         'alpha' = '$\\bar \\alpha$',
#                                         'ECS' = '$\\bar S$',
#                                         'C_UP' = '$\\bar C^{UP}$')) +
#             scale_color_brewer(palette = "Set1") +
#             theme(panel.spacing=grid::unit(0,"lines"),
#                   strip.text.y.right = element_text(angle = 0),
#                   legend.position = "none")
# )
# gg0
# dev.off()
