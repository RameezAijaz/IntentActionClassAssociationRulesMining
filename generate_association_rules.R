library(arules)
totalData <-
  read.transactions(
    "output/transaction_r_format_file.txt",
    format = "basket",
    sep = ",",
    rm.duplicates = FALSE
  )
output_file_name <- "output/apriori_rules.txt"
min_support<-0.00000000000000000000000000000000000000000000000000000000000000000000000001
min_confidence <- 0.3
trainRules <-
  apriori(
    totalData,
    parameter = list(
      support = min_support,
      confidence = min_confidence
    )
  )
trainRules <- sort(trainRules, by = "confidence")
output <- capture.output(inspect(trainRules))
write.table(output,file=output_file_name,sep="\n",row.names = FALSE)