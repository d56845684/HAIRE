import base64
import json

def lambda_handler(event, context):
    output = []

    for record in event['records']:
        payload = base64.b64decode(record['data']).decode('utf-8')

        try:
            json_payload = json.loads(payload)
        except json.JSONDecodeError:
            json_payload = {"message": payload}

        json_data = json.dumps(json_payload) + '\n'

        output_record = {
            'recordId': record['recordId'],
            'result': 'Ok',
            'data': base64.b64encode(json_data.encode('utf-8')).decode('utf-8')
        }

        output.append(output_record)

    return {'records': output}