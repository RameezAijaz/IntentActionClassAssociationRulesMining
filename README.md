# IntentActionClassAssociationRulesMining
An intent is the primary form for requesting an operation from another component or application (app) in Android.  That is, it serves as a mechanism of code reuse or responsibility delegation in Android apps.  Unfortunately, there is very little to no automatic assistance available to developers (e.g., in Android Studio) in locating the potential appropriate intents for the API classes they reuse from the Android software stack.  
An app-marketplace-analytics method to automatically suggest candidate intents for reuse in a specific given source-code class is presented.  Software tools to parse the marketplace apps to acquire and curate requisite information, and patterns/rules of code-intent were implemented.  For example, when a developer is reusing the Android class DialogPreference, the candidate intents android.intent.action.CALL and android.intent.action.VIEW are automatically recommended for use.  Furthermore, an empirical evaluation of the proposed method and tools was conducted on over 40,000 apps from Google Play Store and F-droid marketplaces.    Promising results of this evaluation are also discussed.

for more information about the approach please visit 
https://docs.google.com/document/d/1fmfqpB2dzCkZ75qocVsrb1y7cMnkE0RgxDu4gi20Xsw/

#Repository

This repository contents 
1) apk_decompile.py used to decompile the apk and extrat intents and classes from it.
2) market_basket_transaction_generator.py to merge all the transactions to one file and then convert that to r format
3) generate_association_rules.R to generate association rules
4) k_fold_validation_script.R for the k fold validation
5) Put all the apk file in apks folder then run apk_decompile to fetch intent and classes transactions
6) All the output and error files will be generated in output folder
7) androidstudio_plugin folder contains source code for IntelliJ plugin with rule parser library code which is used by plugin to parse the rule file
8) RealOutput folder contains all the original output files which were generated as a result of runing these scripts on almost 40,000 apk files. 
9) The original result for k fold validation is available on this url https://kfoldvalidation.firebaseapp.com/
 
