#!/usr/local/bin/Rscript
status <- NULL # or e.g. "[DRAFT]"
config <- "Amazon Aurora (r3.8xlarge)\nsysbench 0.5, 100 x 20M rows (2B rows total), 30 minutes per step"
steps <- c(1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024)
time_per_step <- 1800
output_path <- "~/src/demos/aurora_benchmark/same_az_8x/"
test_name <- "01_baseline"


results <- data.frame(
  stringsAsFactors = FALSE,
  row.names = c(
    "amazon_rds_aurora"
  ),
  file = c(
    "~/src/demos/aurora_benchmark/same_az_8x/01_baseline_all.csv"
  ),
  name = c(
    "Amazon Aurora"
  ),
  color = c(
    "magenta"
  )
)


results$data <- lapply(results$file, read.csv, header=FALSE, sep=",", col.names=c("threads", "tps", "reads", "writes", "latency", "errors", "reconnects"))


# TPS
pdf(paste(output_path, test_name, "_tps.pdf", sep=""), width=12, height=8)
plot(0, 0,
  pch=".", col="white", xaxt="n", ylim=c(0,8000), xlim=c(0,length(steps)),
  main=paste(status, "Transaction Rate by Concurrent Sysbench Threads", status, "\n\n"),
  xlab="Concurrent Sysbench Threads",
  ylab="Transaction Rate (tps)"
)
for(result in rownames(results)) {
  tps <- as.data.frame(results[result,]$data)$tps
  points(1:length(tps) / time_per_step, tps, pch=".", col=results[result,]$color, xaxt="n", new=FALSE)
}
title(main=paste("\n\n", config, sep=""), font.main=3, cex.main=0.7)
axis(1, 0:(length(steps)-1), steps)
legend("topleft", results$name, bg="white", col=results$color, pch=15, horiz=FALSE)
dev.off()


# Latency
pdf(paste(output_path, test_name, "_latency.pdf", sep=""), width=12, height=8)
plot(0, 0,
  pch=".", col="white", xaxt="n", ylim=c(0,2000), xlim=c(0,length(steps)),
  main=paste(status, "Latency by Concurrent Sysbench Threads", status, "\n\n"),
  xlab="Concurrent Sysbench Threads",
  ylab="Latency (ms)"
)
for(result in rownames(results)) {
  latency <- as.data.frame(results[result,]$data)$latency
  points(1:length(latency) / time_per_step, latency, pch=".", col=results[result,]$color, xaxt="n", new=FALSE)
}
title(main=paste("\n\n", config, sep=""), font.main=3, cex.main=0.7)
axis(1, 0:(length(steps)-1), steps)
legend("topleft", results$name, bg="white", col=results$color, pch=15, horiz=FALSE)
dev.off()


# TPS per Thread
pdf(paste(output_path, test_name, "_tps_per_thread.pdf", sep=""), width=12, height=8)
plot(0, 0,
  pch=".", col="white", xaxt="n", ylim=c(0,100), xlim=c(0,length(steps)),
  main=paste(status, "Transaction Rate per Thread by Concurrent Sysbench Threads", status, "\n\n"),
  xlab="Concurrent Sysbench Threads",
  ylab="Transactions per thread (tps/thread)"
)
for(result in rownames(results)) {
  tps <- as.data.frame(results[result,]$data)$tps
  threads <- as.data.frame(results[result,]$data)$threads
  points(1:length(tps) / time_per_step, tps / threads, pch=".", col=results[result,]$color, xaxt="n", new=FALSE)
}
title(main=paste("\n\n", config, sep=""), font.main=3, cex.main=0.7)
axis(1, 0:(length(steps)-1), steps)
legend("topleft", results$name, bg="white", col=results$color, pch=15, horiz=FALSE)
dev.off()
