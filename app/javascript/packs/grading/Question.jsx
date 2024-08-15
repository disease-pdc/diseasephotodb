import React, { useEffect, useState } from 'react'

const TYPES = {
  TEXT: 'text',
  SELECT_ONE: 'select_one',
  SELECT_MULTIPLE: 'select_multiple'
};

const LEFT_COLS = 5;
const RIGHT_COLS = 7;

// Question attributes:
// {
//   group,
//   name,
//   type,
//   label,
//   options,
//   hint,
//   relevant,
//   constraint,
//   constrain_message,
//   required
// }

export const Question = ({
  value,
  values,
  state,
  last,
  question,
  groupTitle,
  labelClassName,
  inputClassName,
  onCancel,
  onSubmit
}) => {

  const [editingValue, setEditingValue] = useState(value || 
    question.type === TYPES.SELECT_MULTIPLE ? [] : ''
  );
  const [error, setError] = useState();

  const setMultipleValue = (value, checked) => {
    if (checked && editingValue.indexOf(value) < 0) {
      setEditingValue(editingValue.concat([value]))
    } else if (!checked && editingValue.indexOf(value) > -1) {
      setEditingValue(editingValue.filter(v => v != value))
    }
  }

  const submit = () => {
    setError();
    if (question.constraint) {
      if (!question.constraint(editingValue, values)) {
        setError(question.constraint_message);
        return;
      }
    }
    if (question.required && (!editingValue || /^\s*$/.test(editingValue))) {
      setError("A response is required.");
      return;
    }
    onSubmit(editingValue);
  }

  let el = <span>Question type "{question.type}" not found.</span>;
  if (question.type === TYPES.TEXT) {
    el = (
      <div className="mb-2 row">
        <label htmlFor={question.name} 
          className={`col-lg-${LEFT_COLS} col-form-label text-lg-end`}
        >
          {question.label}
        </label>
        <div className={`col-lg-${RIGHT_COLS}`}>
          <input type="text" 
            className="form-control" 
            id={question.name} name={question.name}
            value={editingValue}
            disabled={state === 'answered'}
            onChange={e => setEditingValue(e.target.value)}
            onKeyPress={e => {if (e.key === 'Enter') submit();} }
          />
        </div>
      </div>
    )
  } else if (question.type === TYPES.SELECT_ONE) {
    el = (
      <div className="mb-2 row">
        <label htmlFor={question.name} 
          className={`col-form-label col-${LEFT_COLS} text-lg-end`}
        >
          {question.label}
        </label>
        <div className={`col-lg-${RIGHT_COLS}`}>
          <select className="form-select"
            name={question.name} id={question.name}
            value={editingValue}
            disabled={state === 'answered'}
            onChange={e => setEditingValue(e.target.value)}
          >
            <option value={null}></option>
            {question.options.map(({value, label}) =>(
              <option key={`${question.name}.${value}`} value={value}>
                {label}
              </option>
            ))}
          </select>
        </div>
      </div>
    )
  } else if (question.type === TYPES.SELECT_MULTIPLE) {
    el = (
      <div className="mb-2 row">
        <label htmlFor={question.name} 
          className={`col-form-label col-${LEFT_COLS} text-lg-end`}
        >
          {question.label}
        </label>
        <div className={`col-lg-${RIGHT_COLS}`}>
          {question.options.map(({value, label}) => (
            <div className="form-check"
              key={`${question.name}.${value}`}
            >
              <input className="form-check-input" 
                type="checkbox" 
                name={value} 
                disabled={state === 'answered'}
                checked={editingValue.indexOf(value) > -1}
                id={`${question.name}.${value}`}
                onChange={e => setMultipleValue(value, e.target.checked)}
              />
              <label className="form-check-label" 
                htmlFor={`${question.name}.${value}`}
              >
                {label}
              </label>
            </div>
          ))}
        </div>
      </div>
    )
  }

  return (
    <div className="Question">
      {groupTitle &&
        <div className="mt-3 row">
          <div className={`offset-lg-${LEFT_COLS}`}>
            <h5>{groupTitle}</h5>
          </div>
        </div>
      }
      {el}
      {error &&
        <div className="alert alert-danger" role="alert">
          {error}
        </div>
      }
      {(state === 'current' || last) && (
        <div className="mb-3 row">
          <div className={`offset-lg-${LEFT_COLS} col-lg-${RIGHT_COLS}`}>
            <button className="btn btn-primary me-1"
              onClick={submit}
            >
              {last ? 'Submit Form' : 'Submit Answer'}
            </button>
            <button className="btn btn-outline-secondary"
              disabled={ onCancel == null }
              onClick={ () => {if (onCancel) onCancel(value);} }
            >
              Back
            </button>
          </div>
        </div>
      )}
    </div>
  )
}