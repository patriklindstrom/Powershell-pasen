I have a few utility powershell script that I use for different task. I have decided to put them on my github repository so maybe others can help me improve them.
I named it powershell påsen. Påsen is swedish for the bag. So i spelled it powershell-pasen. 
run-sql.ps1
Runs all sql script in a folder. Outputs an array of sqlscripts that failed. 
Great for running massive sqlscripts. God for running test sql scripts. Works like: "c:\mysqlscript"|.\run-sql.ps1
backup-db.ps
Backups all databases with certain name pattern. (Eg all that begins with eCM in name) Put them in a folder.
Change-BatchScriptPath
Searche and Replace in files like config files or batfiles. Searches with regular expression and replaces. 
If files are readonly it changes them to writeable.