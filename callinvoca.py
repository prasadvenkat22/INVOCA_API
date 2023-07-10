from pickle import APPEND
from re import S
from sre_constants import SUCCESS
import sys
import requests
import json
import logging
import time
#requesting access token
import requests
import base64
from dotenv import load_dotenv
import os 
import pandas as pd
from pandas import json_normalize
import datetime
from datetime import timedelta, date
import snowflake.connector
from snowflake.connector.pandas_tools import write_pandas

load_dotenv()
API_TOKEN = os.environ.get("API_TOKEN")

def get_json_CSV_Files(  vfrom , vTo, vFilePath         ):

    url = "https://aimediagroup.invoca.net/api/2019-02-01/networks/transactions/1659.json?/"
    url2='https://aimediagroup.invoca.net/api/2019-02-01/networks/transactions/1659.json?from=2022-08-01&to=2022-08-30&oauth_token=Dc_g9nM8zsLzOWnsidpPJ4K9Bg82EnRR'
    query={  'from': vfrom, 'to':vTo ,'limit':'4000'}
    ###query={  'from':'2022-09-01', 'to':'2022-09-15','limit':'4000','include_columns':'transaction_id,corrects_transaction_id'}
    print("Parameters: ",query)
    access_token='Dc_g9nM8zsLzOWnsidpPJ4K9Bg82EnRR'
    my_headers = {'oauth_token=' : '{access_token}'}
    try:
        response = requests.get( url= url, params=query, headers={'Authorization': access_token} )
        print(response.status_code)
        json_data = json.loads(response.text)
        #print(json_data)
        df = json_normalize(json_data)
        print(df.head())
        vFilePath =vFilePath + "transactions_" + vfrom + "_" + vTo + ".csv"
        print(vFilePath)
        df.to_csv( vFilePath, index=False, header=True)
        # Additional code will only run if the request is successful
        print (len(df) )
        if len(df) ==4000:
            print(df.iloc[3999]['transaction_id'])
            transID=df.iloc[3999]['transaction_id']
            get_json_CSV_Files_transactionid(  transID )
    except requests.exceptions.HTTPError as error:
        print(error)

        # This code will run if there is a 404 error.
    #headers = {  'Authorization': 'nxtMEL3asLDdipAqUVGJj3vPBmQyhi36'}
    # from last transaction date ---trick is make the call from transacation ID # keep track of last one
# 
def get_json_CSV_Files_transactionid(  transID      ):
    url = "https://aimediagroup.invoca.net/api/2019-02-01/networks/transactions/1659.json?/"
    url2='https://aimediagroup.invoca.net/api/2019-02-01/networks/transactions/1659.json?from=2022-08-01&to=2022-08-30&oauth_token=Dc_g9nM8zsLzOWnsidpPJ4K9Bg82EnRR'
    query={  'start_after_transaction_id':	transID ,'limit':'4000'}
    ###query={  'from':'2022-01-01', 'to':'2022-08-01','limit':'4000','include_columns':'transaction_id,corrects_transaction_id'}
    print("Parameters: ",query)
    access_token='Dc_g9nM8zsLzOWnsidpPJ4K9Bg82EnRR'
    my_headers = {'oauth_token=' : '{access_token}'}
    try:
        response = requests.get(url ,params=query, headers={'Authorization': access_token} )
        print(response.status_code)
        json_data = json.loads(response.text)
        #print(json_data)
        df = json_normalize(json_data)
        print(df.head())
        df.to_csv( "transactions_" + transID + ".csv", index=False, header=True, APPEND=True)
        # Additional code will only run if the request is successful
        print (len(df) )
        if len(df) ==4000:
            print(df.iloc[3999]['transaction_id'])
            transID=df.iloc[3999]['transaction_id']
            get_json_CSV_Files_transactionid(  transID   )

          

    except requests.exceptions.HTTPError as error:
        print(error)
        # This code will run if there is a 404 error.
    #headers = {  'Authorization': 'nxtMEL3asLDdipAqUVGJj3vPBmQyhi36'}
    # from last transaction date ---trick is make the call from transacation ID # keep track of last one

def daterange(start_date, end_date):
    for n in range(int ((end_date - start_date).days)):
        yield start_date + timedelta(n)


def get_initial_file_start_end_date():
 
    for single_date in daterange(start_date, end_date):
        day_delta = datetime.timedelta(days=1)
        next_date = single_date + day_delta
        strstart_date =  single_date.strftime("%Y-%m-%d")
        strnext_date   =  next_date.strftime("%Y-%m-%d")
        print(strstart_date)
        print(strnext_date)
        get_json_CSV_Files( strstart_date,   strnext_date, "C:/INVOCA_API/")



def get_last_transaction_id_from_snowflake(df):
    try:
        cnn=snowflake.connector.connect(
            user='venkat',
            password='Snowsql123!',
            account='',
            warehouse='compute_wh',
            database='aimedia_dev',
            schema='public'

        )
        cs=cnn.cursor()
        print('connectiong')
      
        sql= ("select max(transaction_id) from transactions  ;")
        recs = cs.execute(sql)
        for rec in recs:
            print(rec)
            strretrun = str(rec)
    except Exception as e:
            print(e)
    finally: 
        print('disconnecting')
        cnn.close()
#
    # # Gets the version
    # ctx = snowflake.connector.connect(
    #     user='<user_name>',
    #     password='<password>',
    #     account='<account_identifier>'
    #     )
    # cs = ctx.cursor()
    # try:
    #     cs.execute("SELECT current_version()")
    #     one_row = cs.fetchone()
    #     print(one_row[0])
    # finally:
    #     cs.close()
    # ctx.close()   

#
    return strretrun

def write_pd_to_snowflake_table(df) :
    try:
        cnn=snowflake.connector.connect(
                user='venkat',
                password='Snowsql123!',
                account='',
                warehouse='compute_wh',
                database='aimedia_dev',
                schema='public'
            )
        success,nchunks,nrows,_ = write_pandas(cnn,df,'transactions',quote_identifiers=False)
        strreturn =  (        str(success) + ',  ' + str(nchunks) + ' ,' + str(nrows)) 
    except Exception as e:
            print(e)
    finally: 
        print('disconnecting')
        cnn.close()
    
get_json_CSV_Files('2022-09-30', '2022-09-30',"C://INVOCA_API//")