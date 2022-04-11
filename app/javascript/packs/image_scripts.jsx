import React, { useEffect, useState } from 'react'
import ReactDOM from 'react-dom'

import { AsyncTypeahead } from 'react-bootstrap-typeahead'
import { get } from 'axios'

import $ from "cash-dom"

const GradingSetSelect = ({
  id,
  targetInput,
  enableButton
}) => {

  const [selectLoading, setSelectLoading] = useState(false)
  const [selectOptions, setSelectOptions] = useState([])
  const [gradingSet, setGradingSet] = useState(null)

  useEffect(() => {
    if (gradingSet) {
      $(targetInput).attr('value', gradingSet.value)
      $(enableButton).attr('disabled', null)
    } else {
      $(targetInput).attr('value', null)
      $(enableButton).attr('disabled', true)
    }
  }, [gradingSet])


  return (
    <AsyncTypeahead
      id={`grading-set-select-${id}`}
      className="mb-3"
      minLength={3}
      filterBy={() => true}
      isLoading={selectLoading}
      options={selectOptions}
      placeholder="Search for a grading set..."
      onSearch={async (query) => {
        setSelectLoading(true)
        setSelectOptions(
          (await get('/grading_sets.json', {params:{text: query}}))
            .data.grading_sets.map((is) => (
              {label: is.name, value: is.id}
            ))
        )
        setSelectLoading(false) 
      }}
      onChange={(value) => setGradingSet(value[0])}
      renderMenuItemChildren={(option, props) => option.label}
    />
  )
}


$(function () {

  // Handle imageid-all checked/unchecked
  $("input[name='image_id_all']").on('change', function(e) {
    $("input[name='image_ids[]'").prop('checked', e.target.checked)
    $("input[name='image_ids[]'").prop('disabled', e.target.checked)
  });

  // Handle page links
  $("a.page-link").on('click', function(e) {
    var offset = e.target.attributes['data-offset'].value;
    $("input[name='offset']").attr('value', offset);
    document.getElementById('search-form').submit();
  })

  $(".grading-set-search").each((index, el) => {
    ReactDOM.render(
      <GradingSetSelect
        id={el.id} 
        targetInput={el.getAttribute('data-target-input')}
        enableButton={el.getAttribute('data-enable-button')}
      />,
      el.appendChild(document.createElement('div'))
    )
  })

});