import json
import datetime

import logging
logger = logging.getLogger()

def handler(event, context):
    data = {
        'output': 'Hello World!',
        'timestamp': datetime.datetime.utcnow().isoformat()
    }
    logger.info(event)
    logger.info(context)

    return {'statusCode': 200,
            'body': json.dumps(data),
            'headers': {'Content-Type': 'application/json'}}
