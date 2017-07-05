# List of hex certificates for internally signed certificate verification.
# See the following gist as an option for generating the hex string using gen_certs.py:
# https://gist.github.com/JustinAzoff/7a1b92c976a2fa6e8601

# Example usage
#default[:seconion][:sensor][:bro][:cert_authorities]["<name_of_CA>"] = "\x2D\x2D\x2D\x2D\x2D.....hex cert string" 