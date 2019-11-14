var AWS = require('aws-sdk');
const fs = require('fs');


const bucketPrefix = 'demopricing-xcomponent';
var s3 = new AWS.S3();

const uploadFile = async (fileContent, fileName) => {
  const params = {
    Bucket: bucketPrefix,
    Key: 'generatedreports/' + fileName,
    Body: fileContent,
    ACL: 'public-read'
  };
  console.log("Uploading files to the bucket");
  await (s3.upload(params).promise());
};


async function generateReport(filename, type, name, id_pricing, asOf) {
  var getParams = {
    Bucket: bucketPrefix,
    Key: 'ReportTemplate/report.htm'
  }

  console.log("Generating report");

  var result = (await (s3.getObject(getParams).promise())).Body.toString();

  result = result.replace(/\$type/g, type)
    .replace(/\$name/g, name)
    .replace(/\$idPricing/g, id_pricing)
    .replace(/\$asOf/g, asOf);

  await uploadFile(result, filename);
}

exports.handler = async (event) => {
  const fileName = Date.now().toString() + ".html";

  await generateReport(
    fileName,
    event.type,
    event.name,
    event.id_pricing,
    event.asOf
  );
  const response = {
    statusCode: 200,
    url: 'https://' + bucketPrefix + '.s3.eu-west-3.amazonaws.com/generatedreports/' + fileName ,
  };
  return response;
};
