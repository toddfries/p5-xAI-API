# p5-xAI-API

This is the perl module with an example client for calling the Grok API.

Head to:
```
https://accounts.x.ai/
```

Then with an API key, set it in the environment for the example client, or
put it in a config for your own app.

```
mkdir -p $HOME/.config/cxai
cat <<EOF > $HOME/.config/cxai/grok.conf
[creds]
bearer = bearertoken
EOF
```

System role explained:

https://x.com/i/grok/share/PZVZOdhwXOpD5VgPrhKPRmEUc
