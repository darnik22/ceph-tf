Host !PROJECT-ceph-*
        GSSAPIAuthentication yes
        ForwardX11Trusted yes
        SendEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
        SendEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
        SendEnv LC_IDENTIFICATION LC_ALL LANGUAGE
        SendEnv XMODIFIERS
        StrictHostKeyChecking no
        VerifyHostKeyDNS ask
        ForwardAgent yes
        GatewayPorts no
Host PROJECT-ceph-*
        StrictHostKeyChecking no
        VerifyHostKeyDNS no
