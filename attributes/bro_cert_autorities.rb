# List of hex certificates for internally signed certificate verification.

# Example usage 
####################   Notes  ######################
# The cert to write in hex is expecting the DER cert.  Here is a conversion from PEM to DER
# openssl x509 -in root.pem -outform der -out root.der
#
# The expected results is the \x2D escaped version be sure to escape the escapes, note the \\ below
#
# See the following gist as an option for generating the hex string using gen_certs.py:
# https://gist.github.com/JustinAzoff/7a1b92c976a2fa6e8601
####################################################
#default[:seconion][:sensor][:bro][:cert_authorities]["<name_of_CA>"] = "\\x2D\\x2D\\x2D\\x2D\\x2D.....hex cert string" 