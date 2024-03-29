\name{clusterSites}
\alias{clusterSites}
\alias{clusterSites,BSraw,ANY,numeric,numeric,numeric,numeric-method}
\alias{clusterSites,BSraw,missing,missing,missing,missing,missing-method}
\alias{clusterSites,BSraw,ANY,numeric,missing,missing,missing-method}
\alias{clusterSites,BSraw,ANY,numeric,numeric,missing,missing-method}
\alias{clusterSites,BSraw,ANY,numeric,numeric,numeric,missing-method}
\alias{clusterSites,BSraw,missing,numeric,numeric,numeric,numeric-method}
\alias{clusterSites,BSraw,missing,numeric,numeric,numeric,missing-method}
\alias{clusterSites,BSraw,ANY,numeric,missing,numeric,missing-method}


\title{
  Assigns CpG cluster memberships on CpG sites within \code{BSraw} objects
}
\description{
Within a \code{BSraw} object \code{clusterSites} searches for agglomerations of CpG sites across
all samples. In a first step the data is reduced to CpG sites covered in
\code{round(perc.samples*ncol(object))} samples, these are
called 'frequently covered CpG sites'. In a second step regions are detected
where not less than \code{min.sites} frequently covered CpG sites are sufficiantly
close to each other (\code{max.dist}). Note, that the frequently covered CpG sites
are considered to define the boundaries of the CpG clusters only. For the subsequent
analysis the methylation data of all CpG sites within these clusters
are used.
}
\usage{
clusterSites(object, groups, perc.samples, min.sites, max.dist,
mc.cores, ...)
}
\arguments{
  \item{object}{
    A \code{BSraw}.
  }
  \item{groups}{
    OPTIONAL. A factor specifying two or more sample groups within the given object. See Details.}
  \item{perc.samples}{
    A numeric between 0 and 1. Is passed to \code{filterBySharedRegions}.
  }
  \item{min.sites}{
    A numeric. Clusters should comprise at least \code{min.sites} CpG sites which
    are covered in at least \code{perc.samples} of samples, otherwise clusters are dropped.
  }
  \item{max.dist}{
    A numeric. CpG sites which are covered in at least
    \code{perc.samples} of samples within a cluster should not be more
    than \code{max.dist} bp apart from their nearest neighbors.
  }
  \item{mc.cores}{
    Passed to \code{mclapply} Default is 1.
  }
  \item{\dots}{
    Further arguments passed to the \code{filterBySharedRegions} function.
  }
}
\details{
Within a \code{BSraw} object this function searches for agglomerations of CpG sites across all samples.
In a first step the data is reduced to CpG sites covered in at least \code{round(perc.samples*ncol(object))} samples.
In a second step regions are defined where not less than
\code{min.sites} of these CpG sites are sufficiantly close. If argument
\code{group} is given \code{perc.samples} or \code{no.samples} are
applied for all group levels.
}

\value{
A \code{BSraw} object reduced to CpG sites within CpG cluster regions. A \code{cluster.id} in the 
\code{elementMetadata} slot of \code{rowData} assigns cluster memberships per CpG site.
}

\author{
Katja Hebestreit
}


\seealso{
\code{\link{filterBySharedRegions}}, \code{mclapply}
}
\examples{
data(rrbs)
rrbs.clust <- clusterSites(object = rrbs, groups = colData(rrbs)$group,
                           perc.samples = 4/5, min.sites = 20,
                           max.dist = 100)
}
