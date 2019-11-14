const uuid = require("uuid/v4");
const helper = require("./helper.js");

const koor = require("./koordinator.js");
const dataset = require("./dataset.json");

const namespace = "Demo";
const name = "LoadPricingContext";

koor.postCatalog({
  namespace: namespace,
  name: name,
  displayName: name,
  inputs: [
    {
      name: "type",
      baseType: "string"
    },
    {
      name: "name",
      baseType: "string"
    },
    {
      name: "asOf",
      baseType: "string"
    }
  ],
  outputs: [
    {
      name: "id_ref_data",
      baseType: "string"
    }
  ],
  versionNumber: 3,
  schemaVersion: 0
});

let listPortfolios = [];

Object.keys(dataset).forEach(desk => {
  listPortfolios = listPortfolios.concat(dataset[desk]);
});

async function load(task, what, global_percentage, allocated_percentage) {
  const delta = allocated_percentage / listPortfolios.length;
  var i = global_percentage;

  for (let index = 0; index < listPortfolios.length; index++) {
    const portfolio = listPortfolios[index];
    const task_percent = (100 * index) / listPortfolios.length;

    await koor.postStatus(task, {
      status: "InProgress",
      message: `Global advancement: ${i.toFixed(
        0
      )}% Load ${what} PTF ${portfolio} task advancement: ${task_percent.toFixed(
        0
      )}%`
    });

    i += delta;
    helper.shortSleep();
  }

  helper.longSleep();

  helper.writeToTopic(task.workflowInstanceId);

  await koor.postStatus(task, {
    status: "InProgress",
    message: `${global_percentage +
      allocated_percentage}% Load ${what} PTF DONE`
  });
}

koor.pollingLoop(namespace, name, async task => {
  await load(task, "position", 0, 25);
  await load(task, "products", 25, 25);
  await load(task, "static data", 50, 25);
  await load(task, "market data", 75, 25);

  helper.longSleep();

  await koor.postStatus(task, {
    status: "Completed",
    outputValues: {
      id_ref_data: uuid()
    }
  });
});
