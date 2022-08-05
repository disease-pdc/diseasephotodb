import React, { useEffect, useState } from 'react'
import ReactDOM from 'react-dom'

import { AsyncTypeahead } from 'react-bootstrap-typeahead'
import { read, utils } from 'xlsx'
import { get, post } from 'axios'

const doUpload = async ({
  authenticityToken,
  imageSourceId,
  filename,
  metadata
}) => {
  const result = await post('/metadata', {
    authenticity_token: authenticityToken,
    image_source_id: imageSourceId,
    filename: filename,
    metadata: metadata
  })
  return result.data
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

const MetadataUpload = ({
  authenticityToken,
  imageSources,
  imageSourceId
}) => {

  const [sourceId, setSourceId] = useState(imageSourceId || -1)

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
            active: '1',
            imageSourceId: sourceId,
            filename: data[i][0],
            metadata: getMetadata({headers, row: data[i]})
          })
          results.push(result)
          setResults(results)
        }
        setFinished(true)
      }
    }
    doEffect().catch(console.error)
  }, [uploading])

  return (
    <>
      {!uploading && 
        <div className="row">
          <div className="col-lg-4">
            <label htmlFor="metadataFile" className="form-label">
              Select Image Source
            </label>
            <select className="form-select mb-3"
              value={imageSourceId}
              onChange={e => setSourceId(e.target.value)}
            >
              <option value="-1"></option>
              {imageSources.map(({id,name}) => (
                <option key={id} value={id}>{name}</option>
              ))}
            </select>
          </div>
          <div className="col-lg-8">
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
              <button disabled={!data || !imageSource || sourceId === "-1"}
                className="btn btn-primary" 
                type="button"
                onClick={() => setUploading(true)}
              >
                Import Metadata
              </button>
            </div>
          </div>
        </div>
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
            {results.map((result, i) => (
              <li key={i}><Result {...result} /></li>
            ))}
          </ul>
        </>
      }
    </>
  )
}

document.addEventListener('DOMContentLoaded', () => {
  const el = document.getElementById('react-app-container')
  ReactDOM.render(
    <MetadataUpload 
      authenticityToken={el.getAttribute('data-authenticity-token')}
      imageSources={JSON.parse(el.getAttribute('data-image-sources'))}
      imageSourceId={el.getAttribute('data-image-source-id')}
    />,
    el.appendChild(document.createElement('div'))
  )
})
