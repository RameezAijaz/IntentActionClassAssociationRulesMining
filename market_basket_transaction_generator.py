#!/usr/bin/python
import os

current_directory_path=os.path.dirname(os.path.realpath(__file__))
output_directory=current_directory_path+'/output'
no_of_processes=6

all_transactions_file = output_directory + '/transactions/all_transactions.txt'
all_transactions_file_stream = open(all_transactions_file, "a")
all_no_intent_file = output_directory + '/no_transactions/all_no_intent.txt'
all_no_intent_file_stream = open(all_no_intent_file, "a")
all_error_file = output_directory + '/errors/all_error.txt'
all_error_file_stream = open(all_error_file, "a")


transaction_r_format_file = output_directory + '/transaction_r_format_file.txt'
transaction_r_format_file_stream = open(transaction_r_format_file, "a")

def concat_all_files(dir,no_of_files,output_file):
    temp=[]
    for i in range(no_of_files):
        temp=temp+[line.rstrip('\n') for line in open(output_directory +dir+str(i)+'.txt')]
    for i, val in enumerate(temp):
        output_file.write(val+ "\n")

print 'copying all intents'
concat_all_files('/transactions/intent_transactions_',no_of_processes,all_transactions_file_stream)
print 'copying all errors'
concat_all_files('/errors/error_file_',no_of_processes,all_error_file_stream)
print 'copying all no intents'
concat_all_files('/no_transactions/apks_with_no_intent_',no_of_processes,all_no_intent_file_stream)

all_transaction = [line.rstrip('\n') for line in
     open(output_directory + '/transactions/all_transactions.txt')]

for transaction in all_transaction:
    temp= transaction.split(',')
    transaction_r_format_file_stream.write(temp[1].replace('i_','')+','+temp[2].replace('c_',''))
    transaction_r_format_file_stream.write("\n")



