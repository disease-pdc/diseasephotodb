import React, { useEffect, useState } from 'react'
import ReactDOM from 'react-dom'

import { AsyncTypeahead } from 'react-bootstrap-typeahead'
import { get } from 'axios'

import $ from "cash-dom"

const UserSelect = ({
  id,
  targetInput,
  enableButton
}) => {

  const [selectLoading, setSelectLoading] = useState(false)
  const [selectOptions, setSelectOptions] = useState([])
  const [user, setUser] = useState(null)

  useEffect(() => {
    if (user) {
      $(targetInput).attr('value', user.value)
      $(enableButton).attr('disabled', null)
    } else {
      $(targetInput).attr('value', null)
      $(enableButton).attr('disabled', true)
    }
  }, [user])

  return (
    <AsyncTypeahead
      id={`user-select-${id}`}
      name="user_id"
      className="mb-3"
      minLength={3}
      filterBy={() => true}
      isLoading={selectLoading}
      options={selectOptions}
      placeholder="Search for a user by email..."
      onSearch={async (query) => {
        setSelectLoading(true)
        setSelectOptions(
          (await get('/users.json', {params:{text: query}}))
            .data.users.map((is) => (
              {label: is.email, value: is.id}
            ))
        )
        setSelectLoading(false) 
      }}
      onChange={(value) => setUser(value[0])}
      renderMenuItemChildren={(option, props) => option.label}
    />
  )
}

$(function () {

  $(".user-search").each((index, el) => {
    ReactDOM.render(
      <UserSelect
        id={el.id} 
        targetInput={el.getAttribute('data-target-input')}
        enableButton={el.getAttribute('data-enable-button')}
      />,
      el.appendChild(document.createElement('div'))
    )
  })

});