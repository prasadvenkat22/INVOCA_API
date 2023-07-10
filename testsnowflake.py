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




def get_last_transaction_id_from_snowflake():
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
      
        sql= ("SELECT current_version();")
        recs = cs.execute(sql)
        for rec in recs:
            print(rec)
            strretrun = str(rec)
    except Exception as e:
            print(e)
    finally: 
        print('disconnecting')
        cnn.close()

   


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


 # Gets the version
def GetSnowVersions():

    ctx = snowflake.connector.connect(
        user='venkat',
        password='Snowsql123!',
        account='KT30101'
        )
    cs = ctx.cursor()
    try:
        cs.execute("SELECT current_version()")
        one_row = cs.fetchone()
        print(one_row[0])
    finally:
        cs.close()
    ctx.close()   


get_last_transaction_id_from_snowflake()