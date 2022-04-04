import React, { useEffect, useState } from 'react'
import ReactDOM from 'react-dom'

import { read, utils } from 'xlsx'
import { post } from 'axios'

const doUpload = async ({
  authenticityToken,
  filename,
  metadata
}) => {
  console.log(authenticityToken)
  console.log(filename)
  console.log(metadata)
  return {
    filename,
    success: true
  }
}

const getMetadata = ({headers, row}) => {
  let metadata = {}
  for (let i = 1; i < headers.length; i++) {
    metadata[headers[i]] = row[i]
  }
  return metadata
}

const Result = ({filename, success, error}) => (
  <>
    {success && 
      <>
        <span className="badge bg-success">Success</span>
        &nbsp;
        <strong>{filename}</strong>
      </>
    }
    {!success &&
      <>
        <span className="badge bg-danger">Error</span>
        &nbsp;
        <strong>{filename}</strong>
        &nbsp;
        <span>{error}</span>
      </>
    }
  </>
)

const MetadataUpload = ({authenticityToken}) => {
  const [data, setData] = useState(null)
  const [uploading, setUploading] = useState(false)
  const [current, setCurrent] = useState(1)
  const [results, setResults] = useState([])
  const [finished, setFinished] = useState(false)

  useEffect(() => {
    const doEffect = async () => {
      if (uploading) {
        const headers = data[0]
        for (let i = 1; i < data.length; i++) {
          setCurrent(i)
          const result = await doUpload({
            authenticityToken,
            filename: data[i][0],
            metadata: getMetadata({headers, row: data[i]})
          })
          results.push(result)
          setResults(results)
          console.log(results)
        }
        setFinished(true)
      }
    }
    doEffect().catch(console.error)
  }, [uploading])

  return (
    <>
      {!uploading && 
        <>
          <label htmlFor="metadataFile" className="form-label">
            Select XLSX Metadata File
          </label>
          <div className="input-group mb-3">
            <input className="form-control" 
              type="file" 
              id="metadataFile" 
              accept="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
              onChange={(e) => {
                const reader = new FileReader()
                reader.onload = function (e) {
                  var data = e.target.result
                  let readedData = read(data, {type: 'binary'})
                  const wsname = readedData.SheetNames[0]
                  const ws = readedData.Sheets[wsname]
                  const dataParse = utils.sheet_to_json(ws, {header:1})
                  setData(dataParse)
                };
                reader.readAsBinaryString(e.target.files[0])
              }}
            />
            <button disabled={!data}
              className="btn btn-primary" 
              type="button"
              onClick={() => setUploading(true)}
            >
              Import Metadata
            </button>
          </div>
        </>
      }
      {uploading &&
        <>
          {!finished &&
            <strong>
              Uploading {current} / {data.length - 1}
            </strong>
          }
          {finished && 
            <div className="alert alert-success" role="alert">
              Upload Complete - {current} uploaded
            </div>
          }
          <ul>
            {results.map((result) => (
              <li><Result {...result} /></li>
            ))}
          </ul>
        </>
      }
    </>
  )
}

document.addEventListener('DOMContentLoaded', () => {
  const el = document.getElementById('react-app-container')
  const token = el.getAttribute('data-authenticity-token')
  ReactDOM.render(
    <MetadataUpload authenticityToken={token} />,
    el.appendChild(document.createElement('div'))
  )
})
