zmprov ms $1 zimbraMailPort 60081
zmprov ms $1 zimbraMailProxyPort 61081
zmprov ms $1 zimbraMailSSLPort 60443
zmprov ms $1 zimbraMailSSLProxyPort 61443
zmprov ms $1 zimbraMtaAuthHost $1
zmcontrol stop
zmcontrol start
