#!/usr/bin/python
from sys import exit
import os
from androguard.core.bytecodes import apk
from androguard.core.bytecodes import dvm
from androguard.decompiler.dad import decompile
from androguard.core.analysis import analysis
from os import listdir
from os.path import isfile, join
import re
from multiprocessing import Process
from multiprocessing import Pool

current_directory_path=os.path.dirname(os.path.realpath(__file__))
apks_directory=current_directory_path+'/apks/'
output_directory=current_directory_path+'/output'
no_of_processes=6
pool = Pool(5)



transaction_r_format_file = output_directory + '/transaction_r_format_file.txt'
transaction_r_format_file_stream = open(transaction_r_format_file, "a")


all_intent_actions_from_file = set(line.rstrip('\n') for line in
                      open('/home/rameez/Desktop/IndependentProject/source/all_intent_actions'))

all_android_classes_from_file = set(line.rstrip('\n') for line in
                       open('/home/rameez/Desktop/IndependentProject/source/android_classes.txt'))


def convert_descriptor(name):
    name = name[1:]
    return name.replace("/", ".").replace(";", "")

def class_is_android(all_classes,name):
    for class_name in all_classes:
        name=name.rsplit('/', 1)[-1]
        name=name.replace(';', '')
        if name in class_name:
                return True
    return False

def get_android_super_class(all_android_classes,super_class_name,d):
    temp = True
    android_super_class=super_class_name
    while temp:
        if d.get_class(android_super_class) is None or class_is_android(all_android_classes,android_super_class):
            break
        android_super_class = d.get_class(android_super_class).get_superclassname()
    return android_super_class

android_classes=[]

def get_all_intents_with_super_classs(a,total,apk_index,process_no):
    print('Process no '+process_no+' processing '+a.get_package()+'............('+str(apk_index)+'/'+str(total)+')')
    try:
        package_name = a.get_package().encode('utf-8')
        d = dvm.DalvikVMFormat(a.get_dex())
        vmx = analysis.newVMAnalysis(d)
        intents_with_super_class = []
        all_android_classes=all_android_classes_from_file
        all_intent_actions = all_intent_actions_from_file
        for _class in d.get_classes():
            class_path = convert_descriptor(_class.get_name())
            if package_name not in class_path:
                continue
            for method in _class.get_methods():
                class_name = _class.get_name()
                super_class_name = _class.get_superclassname()
                android_super_class=get_android_super_class(all_android_classes,super_class_name,d)
                g = vmx.get_method(method)
                if method.get_code() == None:
                    continue
                ms = decompile.DvMethod(g)
                ms.process()
                for line in ms.get_source().split("\n"):
                    if 'new android.content.Intent' in line:
                        intent_action = re.findall('"([^"]*)"', line)
                        if(len(intent_action)<1 ):
                            continue
                        intent_action = intent_action[0]
                        if intent_action in all_intent_actions:
                            intents_with_super_class.append(dict(intent=intent_action,class_name=class_name,super_class_name=super_class_name,android_super_class=android_super_class))
    except Exception as e:
        print "__________ERROR____________"
        print e.message
        return []
    return intents_with_super_class



def write_intents_transactions_to_txt_file(apk,intent_transactions_text_file_stream):
    for data in apk['apk_intent_with_super_class']:
        print '____________________________________________writing__________________________________________'
        intent_transactions_text_file_stream.write('a_'+apk['apk_name']+','+'i_'+data['intent'] + ','+ 'c_'+data['android_super_class'].rsplit('/', 1)[-1].replace(';', '')+"\n")

if not os.path.exists(output_directory):
    print "Output directory '%s' does not exist..." % (output_directory)
    exit(1)
if not os.path.exists(apks_directory):
    print "Apk directory '%s' does not exist..." % (apks_directory)
    exit(1)


apk_files = [f for f in listdir(apks_directory) if (isfile(join(apks_directory, f)))]
#
# for file in apk_files_total:
#     if apk_is_unprocessed(file):
#         print file
#         all_unprocessed_apks_file_stream.write("%s\n" % file)



if len(apk_files)==0:
    print "No Apk found in %s" % (apks_directory)
    exit(1)

total = len(apk_files)
size = int(total/no_of_processes)
def processApkBatch(arg,process_no):
    all_apks_intent_with_super_class = []
    file_index = 1
    intent_transactions_text_file = output_directory + '/transactions/intent_transactions_'+process_no+'.txt'
    apks_with_no_intent_file = output_directory + '/no_transactions/apks_with_no_intent_'+process_no+'.txt'
    apks_with_no_intent_file_stream = open(apks_with_no_intent_file, "a")
    intent_transactions_text_file_stream = open(intent_transactions_text_file, "a")
    error_text_file = output_directory + '/errors/error_file_' + str(i) + '.txt'
    error_file_stream = open(error_text_file, "a")
    for file in arg:
        try:
            a = apk.APK(apks_directory+'/'+file)
            apk_intent_with_super_class=get_all_intents_with_super_classs(a,len(arg),file_index,process_no)
            if (len(apk_intent_with_super_class) < 1):
                file_index = file_index + 1
                apks_with_no_intent_file_stream.write(file+"\n")
                continue
            write_intents_transactions_to_txt_file(dict(apk_name=file, apk_intent_with_super_class=apk_intent_with_super_class),intent_transactions_text_file_stream)
            file_index = file_index + 1
        except Exception as e:
            print "__________ERROR____________"
            print e.message
            print 'process '+process_no
            error_file_stream.write("_____ERROR___________")
            error_file_stream.write("\n")
            error_file_stream.write(e.message)



processes = []
print 'total no. of processes'+str(no_of_processes)
print 'total no. of apks '+str(total)
print 'total no of apk per process '+str(size)
for i in range(no_of_processes):
    start = i*size
    end = (i+1)*size
    if(i==no_of_processes-1):
        end = total
    p = Process(target=processApkBatch, args=(apk_files[start:end],str(i),))
    p.start()
    processes.append(p)



