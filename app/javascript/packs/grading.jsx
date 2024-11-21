import React, { useEffect, useState } from 'react'
import ReactDOM from 'react-dom'

import { FGSGrading } from './grading/FGSGrading'
import { TrachomaGrading } from './grading/TrachomaGrading'

const Grading = ({
  gradingType,
  submitUrl,
  gradingSetImage
}) => {

  return (
    <>
      {gradingType === 'FGSGrading' && 
        <FGSGrading 
          gradingSetImage={gradingSetImage} 
          submitUrl={submitUrl}
        />
      }
      {gradingType === 'TrachomaGrading' && 
        <TrachomaGrading gradingSetImage={gradingSetImage} />
      }
    </>
  )
}

document.addEventListener('DOMContentLoaded', () => {
  const el = document.getElementById('react-app-container')
  ReactDOM.render(
    <Grading 
      gradingSetImage={JSON.parse(el.getAttribute('data-grading-set-image'))}
      gradingType={el.getAttribute('data-grading-type')}
      submitUrl={el.getAttribute('data-submit-url')}
    />,
    el.appendChild(document.createElement('div'))
  )
})