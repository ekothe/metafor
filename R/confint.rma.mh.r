confint.rma.mh <- function(object, parm, level, digits, transf, targs, ...) {

   mstyle <- .get.mstyle("crayon" %in% .packages())

   if (!inherits(object, "rma.mh"))
      stop(mstyle$stop("Argument 'object' must be an object of class \"rma.mh\"."))

   x <- object

   if (missing(level))
      level <- x$level

   if (missing(digits)) {
      digits <- .get.digits(xdigits=x$digits, dmiss=TRUE)
   } else {
      digits <- .get.digits(digits=digits, xdigits=x$digits, dmiss=FALSE)
   }

   if (missing(transf))
      transf <- FALSE

   if (missing(targs))
      targs <- NULL

   #########################################################################

   level <- ifelse(level == 0, 1, ifelse(level >= 1, (100-level)/100, ifelse(level > .5, 1-level, level)))
   crit  <- qnorm(level/2, lower.tail=FALSE)

   beta <- x$beta
   ci.lb <- beta - crit * x$se
   ci.ub <- beta + crit * x$se

   ### if requested, apply transformation function

   if (.isTRUE(transf) && is.element(x$measure, c("OR","RR","IRR"))) ### if transf=TRUE, apply exp transformation to ORs, RRs, and IRRs
      transf <- exp

   if (is.function(transf)) {
      if (is.null(targs)) {
         beta  <- sapply(beta, transf)
         ci.lb <- sapply(ci.lb, transf)
         ci.ub <- sapply(ci.ub, transf)
      } else {
         beta  <- sapply(beta, transf, targs)
         ci.lb <- sapply(ci.lb, transf, targs)
         ci.ub <- sapply(ci.ub, transf, targs)
      }
   }

   #########################################################################

   res <- cbind(estimate=beta, ci.lb, ci.ub)
   res <- list(fixed=res)
   rownames(res$fixed) <- ""

   res$digits <- digits

   class(res) <- "confint.rma"
   return(res)

}
