import { DynamoDB } from 'aws-sdk'
import crypto from 'crypto'

export async function list(event, context) {
    const dynamodb = new DynamoDB({
        region: 'ap-northeast-1'
    })

    // DynamoDB.scan メソッドを await して結果を取得
    const result = await dynamodb.scan({
        TableName: 'tasks'
    }).promise()

    // もし Items が存在しない場合は空の配列にデフォルトで設定
    const items = result.Items || []

    // map メソッドの前にデータの存在を確認
    const tasks = items.map((item) => {
        return {
            id: item.id.S,
            title: item.title.S
        }
    })

    return { tasks: tasks }
}

export async function post(event, context) {
    const requestBody = JSON.parse(event.body)

    const item = {
        id: { S: crypto.randomUUID() },
        title: { S: requestBody.title }
    }

    const dynamodb = new DynamoDB({
        region: 'ap-northeast-1'
    })

    await dynamodb.putItem({
        TableName: 'tasks',
        Item: item
    }).promise()

    return item
}

