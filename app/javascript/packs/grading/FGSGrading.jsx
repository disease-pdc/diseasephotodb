import React, { useEffect, useState } from 'react'
import ReactDOM from 'react-dom'

export const FGSGrading = ({
  userGradingSet
}) => {

  return (
    <div className="FGSGrading">
      FGS Grading
      <pre>
        {JSON.stringify(userGradingSet, null, 2)}
      </pre>
    </div>
  )
}