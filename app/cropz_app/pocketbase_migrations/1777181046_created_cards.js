/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = new Collection({
    "createRule": "@request.auth.id != \"\"",
    "deleteRule": "user_id = @request.auth.id || @request.auth.role = \"owner\"",
    "fields": [
      {
        "autogeneratePattern": "[a-z0-9]{15}",
        "help": "",
        "hidden": false,
        "id": "text3208210256",
        "max": 15,
        "min": 15,
        "name": "id",
        "pattern": "^[a-z0-9]+$",
        "presentable": false,
        "primaryKey": true,
        "required": true,
        "system": true,
        "type": "text"
      },
      {
        "autogeneratePattern": "",
        "help": "",
        "hidden": false,
        "id": "text2809058197",
        "max": 24,
        "min": 0,
        "name": "user_id",
        "pattern": "",
        "presentable": false,
        "primaryKey": false,
        "required": true,
        "system": false,
        "type": "text"
      },
      {
        "autogeneratePattern": "",
        "help": "",
        "hidden": false,
        "id": "text626767331",
        "max": 32,
        "min": 0,
        "name": "owner_key",
        "pattern": "",
        "presentable": false,
        "primaryKey": false,
        "required": true,
        "system": false,
        "type": "text"
      },
      {
        "autogeneratePattern": "",
        "help": "",
        "hidden": false,
        "id": "text3663736680",
        "max": 96,
        "min": 0,
        "name": "card_key",
        "pattern": "",
        "presentable": false,
        "primaryKey": false,
        "required": true,
        "system": false,
        "type": "text"
      },
      {
        "help": "",
        "hidden": false,
        "id": "json966904008",
        "maxSize": 0,
        "name": "payload_json",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      },
      {
        "help": "",
        "hidden": false,
        "id": "bool3946532403",
        "name": "deleted",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "bool"
      },
      {
        "help": "",
        "hidden": false,
        "id": "number3675805968",
        "max": null,
        "min": 0,
        "name": "updated_at_ms",
        "onlyInt": false,
        "presentable": false,
        "required": true,
        "system": false,
        "type": "number"
      }
    ],
    "id": "pbc_3481593366",
    "indexes": [
      "CREATE UNIQUE INDEX IF NOT EXISTS idx_cards_card_key ON cards (card_key)",
      "CREATE INDEX IF NOT EXISTS idx_cards_user_deleted ON cards (user_id, deleted)"
    ],
    "listRule": "user_id = @request.auth.id || @request.auth.role = \"owner\"",
    "name": "cards",
    "system": false,
    "type": "base",
    "updateRule": "user_id = @request.auth.id || @request.auth.role = \"owner\"",
    "viewRule": "user_id = @request.auth.id || @request.auth.role = \"owner\""
  });

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_3481593366");

  return app.delete(collection);
})
