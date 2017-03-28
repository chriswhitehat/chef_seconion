# Local Rules Example


##########################
# Global
##########################

# Example
# default[:seconion][:sensor][:local_rules]['global']["ET POLICY Office Document Containing Workbook_Open Macro Via smtp"] = 'alert tcp $EXTERNAL_NET any -> $SMTP_SERVERS [25,587] '\
# 																																												'(msg:"ET POLICY Office Document Containing Workbook_Open Macro Via smtp"; '\
# 																																												'flow:established,to_server; '\
# 																																												'content:"VwBvcmtib29rXwBPcGVu"; '\
# 																																												'reference:url,support.microsoft.com/kb/286310,http://www.mrexcel.com/forum/excel-questions/7471-autoexec-macro-question.html; '\
# 																																												'classtype:policy-violation; '\
# 																																												'sid:1000047; '\
# 								
 
##########################
# Regional
##########################

# Example
# default[:seconion][:sensor][:local_rules][:regional]["ET POLICY Office Document Containing Workbook_Open Macro Via smtp"] = 'alert tcp $EXTERNAL_NET any -> $SMTP_SERVERS [25,587] '\
# 																																												'(msg:"ET POLICY Office Document Containing Workbook_Open Macro Via smtp"; '\
# 																																												'flow:established,to_server; '\
# 																																												'content:"VwBvcmtib29rXwBPcGVu"; '\
# 																																												'reference:url,support.microsoft.com/kb/286310,http://www.mrexcel.com/forum/excel-questions/7471-autoexec-macro-question.html; '\
# 																																												'classtype:policy-violation; '\
# 																																												'sid:1000047; '\
# 																																												'rev:2;)'

##########################
# Sensor Group
##########################

# Example
# default[:seconion][:sensor][:local_rules]['sensor_group_name']["ET POLICY Office Document Containing Workbook_Open Macro Via smtp"] = 'alert tcp $EXTERNAL_NET any -> $SMTP_SERVERS [25,587] '\
# 																																												'(msg:"ET POLICY Office Document Containing Workbook_Open Macro Via smtp"; '\
# 																																												'flow:established,to_server; '\
# 																																												'content:"VwBvcmtib29rXwBPcGVu"; '\
# 																																												'reference:url,support.microsoft.com/kb/286310,http://www.mrexcel.com/forum/excel-questions/7471-autoexec-macro-question.html; '\
# 																																												'classtype:policy-violation; '\
# 																																												'sid:1000047; '\
# 																																												'rev:2;)'

##########################
# Host
##########################

# Example
# default[:seconion][:sensor][:local_rules]['sosensor']["ET POLICY Office Document Containing Workbook_Open Macro Via smtp"] = 'alert tcp $EXTERNAL_NET any -> $SMTP_SERVERS [25,587] '\
# 																																												'(msg:"ET POLICY Office Document Containing Workbook_Open Macro Via smtp"; '\
# 																																												'flow:established,to_server; '\
# 																																												'content:"VwBvcmtib29rXwBPcGVu"; '\
# 																																												'reference:url,support.microsoft.com/kb/286310,http://www.mrexcel.com/forum/excel-questions/7471-autoexec-macro-question.html; '\
# 																																												'classtype:policy-violation; '\
# 																																												'sid:1000047; '\
# 								

##########################
# Sensor 
##########################

# Example
# default[:seconion][:sensor][:local_rules]['sensorname']["ET POLICY Office Document Containing Workbook_Open Macro Via smtp"] = 'alert tcp $EXTERNAL_NET any -> $SMTP_SERVERS [25,587] '\
# 																																												'(msg:"ET POLICY Office Document Containing Workbook_Open Macro Via smtp"; '\
# 																																												'flow:established,to_server; '\
# 																																												'content:"VwBvcmtib29rXwBPcGVu"; '\
# 																																												'reference:url,support.microsoft.com/kb/286310,http://www.mrexcel.com/forum/excel-questions/7471-autoexec-macro-question.html; '\
# 																																												'classtype:policy-violation; '\
# 																																												'sid:1000047; '\
# 								