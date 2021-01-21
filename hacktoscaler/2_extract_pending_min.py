import pandas as pd
now = pd.Timestamp.utcnow()
pending = pd.read_csv("pending_pods.txt", delimiter=";", parse_dates=["time"])
minutes = 0
if len(pending) > 0:
    minutes = (now - pending.time.min()).seconds // 60
print(minutes)
