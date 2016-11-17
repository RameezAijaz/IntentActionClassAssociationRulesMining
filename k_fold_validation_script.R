library(arules)
totalData <-
  read.transactions(
    "data/intent_transactions.txt",
    format = "basket",
    sep = ",",
    rm.duplicates = FALSE
  )
output_file_name <- "output_conf_0.4.html"
totalData <- totalData[sample(nrow(totalData)), ]
min_support<-0.00000000000000000000000000000000000000000000000000000000000000000000000001;
min_confidence <- 0.4;
#Create 10 equally size folds
folds <- cut(seq(1, nrow(totalData)), breaks = 10, labels = FALSE)

#Perform 10 fold cross validation

result_list = list()

cat('<html lang="en">', file = output_file_name)

cat('<head>', file = output_file_name, append = TRUE)
cat('<meta charset="UTF-8">', file = output_file_name, append = TRUE)
cat('<title>10 Fold Validation</title><link rel="stylesheet" href="bootstrap.min.css">', file = output_file_name, append = TRUE)

cat('</head>', file = output_file_name, append = TRUE)
cat('<body>', file = output_file_name, append = TRUE)

cat(paste('<div class="row">
          <div class="col-xs-4"></div>
          <div class="col-xs-4 text-center">
          <h2>10 Fold Validation</h2>
          <h5>Min Support :',min_support,'</h5>
          <h5>Min confidence :', min_confidence,'</h5>
          </div><div class="col-xs-4"></div>
          </div>'),
    file = output_file_name,
    append = TRUE)

cat("<div class='container'>",
    file = output_file_name,
    append = TRUE)


index = 1

totalTruePositives <- 0
totalTrueNegatives <- 0
totalFalsePositives <- 0
totalFalseNegatives <- 0
all_precisions = list();
all_recalls = list();

for (i in 1:10) {
  #Segement your data by fold using the which() function
  testIndexes <- which(folds == i, arr.ind = TRUE)
  testData <- totalData[testIndexes, ]
  trainData <- totalData[-testIndexes, ]
  testDataList <- as(testData, 'list')
  cat(paste('<h2>Fold ',i,'</h2>'),
      file = output_file_name,
      append = TRUE)
  
  totalTruePositivesPerFold <- 0
  totalFalsePositivesPerFold <- 0
  
  
  cat(paste('<table class="table table-striped table-bordered">\n'),
      file = output_file_name,
      append = TRUE)
  cat('<thead><tr>
      <th>#</th><th>Test Data Class</th>
      <th>Test Data Intent</th>
      <th>Predicted Intent</th>
      <th>Confidence</th>
      <th>Support</th>
      <th>Precision</th>
      <th>Recall</th>
      </tr>
      </thead>\n',
      file = output_file_name,
      append = TRUE)
  cat('<tbody>',
      file = output_file_name,
      append = TRUE)
  #Use the test and train data partitions however you desire...
  trainRules <-
    apriori(
      trainData,
      parameter = list(
        support = min_support,
        confidence = min_confidence
      )
    )
  trainRules <- sort(trainRules, by = "confidence")
  w <- 1
  
  testDataGroupedByClass <- list()
  
  for (data in testDataList)
  {
    if(is.na(data[2]) || is.na(data[1]))
    {
      cat('______________________NA_________________________________');
      cat(data);
      next;
    }
    class_name<-data[2]
    intent_name<-data[1]
    if(grepl("android.",class_name))
    {
      class_name<-data[1];
      intent_name <-data[2]
    }
    if (is.null(testDataGroupedByClass[[class_name]]))
    {
      w <- 1
      testDataGroupedByClass[[class_name]] = list()
    }
    else{
      w <- length(testDataGroupedByClass[[class_name]]) + 1
      
    }
    if ((intent_name %in% testDataGroupedByClass[[class_name]]) == FALSE)
    {
      
      testDataGroupedByClass[[class_name]][w] = intent_name
      
      w <- w + 1
      
    }
  }
  index <- 1;
  for (name_index in 1:length(names(testDataGroupedByClass)))
  {
    name <- as.list(names(testDataGroupedByClass))[[name_index]]
    cat('<tr>',
        file = output_file_name,
        append = TRUE)
    
    truePositives <- 0
    trueNegatives <- 0
    falsePositives <- 0
    falseNegatives <- 0
    # find all rules, where the lhs is a subset of the current basket
    rulesLHSMatchTestDataRHS <-subset(trainRules, subset = lhs %in% name)
    
    cat(paste('<td>',index,'</td>'),
        file = output_file_name,
        append = TRUE)
    
    cat(paste('<td>',name,'</td>'),
        file = output_file_name,
        append = TRUE)
    
    predicted_intents=''
    confidence_string=''
    support_string=''
    
    
    test_intents_string=''
    
    for(intent in testDataGroupedByClass[name])
    {
      
      test_intents_string<-paste(test_intents_string,"<label class='label label-default' style='display: inline-block !important'>",intent,"</label>");
      
    }
    cat("<td>",
        file = output_file_name,
        append = TRUE)
    cat(test_intents_string,
        file = output_file_name,
        append = TRUE)
    
    cat("</td>",
        file = output_file_name,
        append = TRUE)
    if (length(rulesLHSMatchTestDataRHS@rhs) == 0)
    {
      
      predicted_intents<-'no rule found for this class'
      
    }
    else{
      
      for (m in 1:length(rulesLHSMatchTestDataRHS@rhs))
      {
        value <- gsub("\\d|\\s+|\\{|\\}|\\[|\\]", "", capture.output(inspect(rulesLHSMatchTestDataRHS@rhs[m]))[2])
        
        support <- round(rulesLHSMatchTestDataRHS[m]@quality$support,digits=3)
        confidence <- round(rulesLHSMatchTestDataRHS[m]@quality$confidence,digits = 3)
        for(intent in testDataGroupedByClass[name])
        {
          
          if (value %in% intent)
          {
            truePositives = truePositives + 1;
            predicted_intents<-paste(predicted_intents,'<label class="label label-success" style="display: inline-block !important">',value,'</label>');
            confidence_string<-paste(confidence_string,'<label class="label label-success" style="display: inline-block !important">',confidence,'</label>');
            
            support_string<-paste(support_string,'<label class="label label-success" style="display: inline-block !important">',support,'</label>');
          }
          else{
            
            predicted_intents<-paste(predicted_intents,'<label class="label label-danger" style="display: inline-block !important">',value,'</label>');
            confidence_string<-paste(confidence_string,'<label class="label label-danger" style="display: inline-block !important">',confidence,'</label>');
            
            support_string<-paste(support_string,'<label class="label label-danger" style="display: inline-block !important">',support,'</label>');
          }
          
        }
        falsePositives = length(rulesLHSMatchTestDataRHS@rhs) - truePositives;
      }
    }
    
    
    
    
    
    
    cat('\n________________test_intents______________\n')
    cat(test_intents_string)
    cat('\n________________predicted_intents______________\n')
    cat(predicted_intents)
    
    
    cat(paste('<td>',predicted_intents,'</td>'),
        file = output_file_name,
        append = TRUE)
    cat(paste('<td>',confidence_string,'</td>'),
        file = output_file_name,
        append = TRUE)
    cat(paste('<td>',support_string,'</td>'),
        file = output_file_name,
        append = TRUE)
    
    precision <- 0;
    recall <- 0 ;
    if(truePositives<=0 && falsePositives <=0)
    {
      
      cat(paste('<td>','N/A','</td>'),
          file = output_file_name,
          append = TRUE)
      cat(paste('<td>','0','</td>'),
          file = output_file_name,
          append = TRUE)
      
    }
    else{
      
      precision <- round((truePositives/(truePositives+falsePositives)),digits=3);
      recall <- round(truePositives/length(testDataGroupedByClass[[name]]),digits = 3);
      
      cat(paste('<td>',truePositives,'/',(truePositives+falsePositives),' = ',precision,'</td>'),
          file = output_file_name,
          append = TRUE)
      
      cat(paste('<td>',truePositives,'/',length(testDataGroupedByClass[[name]]),' = ',recall,'</td>'),
          file = output_file_name,
          append = TRUE)
    }
    
    
    all_precisions<- c(all_precisions, c=precision)
    all_recalls<- c(all_recalls, c=recall)
    
    totalTruePositivesPerFold = totalTruePositivesPerFold + truePositives
    totalFalsePositivesPerFold = totalFalsePositivesPerFold + falsePositives
    cat('</tr>',
        file = output_file_name,
        append = TRUE)
    index <- index+1;
  }
  
  
  totalTruePositives = totalTruePositives + totalTruePositivesPerFold;
  totalFalsePositives = totalFalsePositives + totalFalsePositivesPerFold;
  
  cat('</tbody>',
      file = output_file_name,
      append = TRUE)
  cat(paste('</table>'),
      file = output_file_name,
      append = TRUE)
}

min_recall<-0;
max_recall<-0;
total_recall <-0;
avg_recall<-0;
min_precision<-0;
max_precision<-0;
total_precision <- 0;
avg_precision<-0;

for(item in all_precisions)
{
  if(item<min_precision)
  {
    min_precision = item;
  }
  if(item>max_precision)
  {
    max_precision = item;
  }
  total_precision <- total_precision + item;
}
avg_precision <- round(total_precision/length(all_precisions), digits = 3);
for(item in all_recalls)
{
  if(item<min_recall)
  {
    min_recall = item;
  }
  if(item>max_recall)
  {
    max_recall = item;
  }
  total_recall <- total_recall + item;
}
avg_recall<- round(total_recall/length(all_recalls), digits = 3);


cat("<table class='table table-striped table-bordered'>",
    file = output_file_name,
    append = TRUE)
cat("<thead>",
    file = output_file_name,
    append = TRUE)
cat("<tr>",
    file = output_file_name,
    append = TRUE)
cat("<th>Min. Precision</th>",
    file = output_file_name,
    append = TRUE)
cat("<th>Max. Precision</th>",
    file = output_file_name,
    append = TRUE)
cat("<th>Avg. Precision</th>",
    file = output_file_name,
    append = TRUE)
cat("</tr>",
    file = output_file_name,
    append = TRUE)
cat("</thead>",
    file = output_file_name,
    append = TRUE)


cat("<tbody>",
    file = output_file_name,
    append = TRUE)

cat("<tr>",
    file = output_file_name,
    append = TRUE)

cat("<td>",min_precision,"</td>",
    file = output_file_name,
    append = TRUE)

cat("<td>",max_precision,"</td>",
    file = output_file_name,
    append = TRUE)

cat("<td>",avg_precision,"</td>",
    file = output_file_name,
    append = TRUE)
cat("</tr>",
    file = output_file_name,
    append = TRUE)
cat("</tbody>",
    file = output_file_name,
    append = TRUE)
cat("</table>",
    file = output_file_name,
    append = TRUE)


cat("<table class='table table-striped table-bordered'>",
    file = output_file_name,
    append = TRUE)
cat("<thead>",
    file = output_file_name,
    append = TRUE)
cat("<tr>",
    file = output_file_name,
    append = TRUE)
cat("<th>Min. Recall</th>",
    file = output_file_name,
    append = TRUE)
cat("<th>Max. Recall</th>",
    file = output_file_name,
    append = TRUE)
cat("<th>Avg. Recall</th>",
    file = output_file_name,
    append = TRUE)
cat("</tr>",
    file = output_file_name,
    append = TRUE)
cat("</thead>",
    file = output_file_name,
    append = TRUE)


cat("<tbody>",
    file = output_file_name,
    append = TRUE)

cat("<tr>",
    file = output_file_name,
    append = TRUE)

cat("<td>",min_recall,"</td>",
    file = output_file_name,
    append = TRUE)

cat("<td>",max_recall,"</td>",
    file = output_file_name,
    append = TRUE)

cat("<td>",avg_recall,"</td>",
    file = output_file_name,
    append = TRUE)
cat("</tr>",
    file = output_file_name,
    append = TRUE)
cat("</tbody>",
    file = output_file_name,
    append = TRUE)
cat("</table>",
    file = output_file_name,
    append = TRUE)
cat("</div>",
    file = output_file_name,
    append = TRUE)

cat('</body>', file = output_file_name, append = TRUE)

cat('</html>', file = output_file_name, append = TRUE)