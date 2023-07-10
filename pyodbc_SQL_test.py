# def list_duplicates(seq):
#   seen = set()
#   seen_add = seen.add
#   # adds all elements it doesn't know yet to seen and all other to seen_twice
#   seen_twice = set( x for x in seq if x in seen or seen_add(x) )
#   # turn the set into a list (as requested)
#   return list( seen_twice )

# a = [1,2,3,2,1,5,6,5,5,5]
# list_duplicates(a) # yields [1, 2, 5]

import pyodbc
# DBconnect.py
import urllib
#insightsssrs.eastus.cloudapp.azure.com
cnxn_str = ("Driver={SQL Server Native Client 11.0};"
            "Server=20.120.110.199;"
            "Database=SampleDB;"
            "UID=ssrsuser;"
            "PWD=Welcome123!;")

# ENCRYPT defaults to yes starting in ODBC Driver 18. It's good to always specify ENCRYPT=yes on the client side to avoid MITM attacks.
cnxn = pyodbc.connect(cnxn_str)
cursor = cnxn.cursor()

cursor.execute("SELECT * FROM DimDate") 
row = cursor.fetchone() 
while row:
    print (row) 
    row = cursor.fetchone()