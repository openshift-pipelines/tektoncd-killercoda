#!/bin/bash
# Verify step 3: signature and payload files exist from verification exercise
ls /tmp/signature.raw &>/dev/null && ls /tmp/payload.raw &>/dev/null
