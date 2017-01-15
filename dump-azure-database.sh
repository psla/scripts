#!/bin/bash
mysqldump -u bf2cf8c40afdbc --ssl --host=us-cdbr-azure-east-c.cloudapp.net pslablog_db -p > wordpressdump.sql
