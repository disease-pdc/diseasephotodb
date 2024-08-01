import React, { useEffect, useState } from 'react'
import ReactDOM from 'react-dom'

import { FGSGrading } from './grading/FGSGrading'
import { TrachomaGrading } from './grading/TrachomaGrading'

const Grading = ({
  gradingType,
  userGradingSet
}) => {

  const saveGradingSetImage = (gradingSetImage) => {
    // save grading set image
    // return next grading set image
  }

  return (
    <>
      {gradingType === 'FGSGrading' && 
        <FGSGrading userGradingSet={userGradingSet} />
      }
      {gradingType === 'TrachomaGrading' && 
        <TrachomaGrading userGradingSet={userGradingSet} />
      }
    </>
  )
}

document.addEventListener('DOMContentLoaded', () => {
  const el = document.getElementById('react-app-container')
  ReactDOM.render(
    <Grading 
      authenticityToken={el.getAttribute('data-authenticity-token')}
      userGradingSet={JSON.parse(el.getAttribute('data-user-grading-set'))}
      gradingType={el.getAttribute('data-grading-type')}
    />,
    el.appendChild(document.createElement('div'))
  )
})