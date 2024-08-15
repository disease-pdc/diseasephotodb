import React, { useEffect, useState } from 'react'

import { Question } from './Question'

export const GradeableQuestionnaire = ({
  groups,
  questions,
  gradeable,
  values,
  setValues
}) => {

  const [inputValues, setInputValues] = useState(values);

  const getQuestionGroup = (question) => {
    if (!question.group) return null;
    for (let i = 0; i < groups.length; i++) {
      if (question.group === groups[i].name) return groups[i];
    }
  }

  // Question states:
  // answered, skipped, current
  const getQuestionState = (question) => {
    // If question is in a group check group relevance first:
    const group = getQuestionGroup(question);
    if (group && group.relevant && !group.relevant(inputValues) ) {
      return 'skipped';
    }

    if (question.relevant && !question.relevant(inputValues)) {
      return 'skipped';
    } else if (typeof inputValues[question.name] != 'undefined') {
      return 'answered';
    } else {
      return 'current';
    }
  }

  const getCurrentQuestions = () => {
    let currentQuestions = [];
    let groupTitle = null;
    for (let i = 0; i < questions.length; i++) {
      const state =  getQuestionState(questions[i]);
      if (state != 'skipped') {
        currentQuestions.push({
          question: questions[i],
          state: state
        })
        if (state === 'current') break;
      }
    }
    let els = []
    for (let i = 0; i < currentQuestions.length; i++) {
      const prevQuestion = i > 0 ? currentQuestions[i-1].question : null;
      const question = currentQuestions[i].question;
      const state = currentQuestions[i].state;
      const group = getQuestionGroup(question);
      const last = state != 'current' && i == currentQuestions.length - 1;
      els.push(
        <Question key={question.name} 
          question={question} 
          value={inputValues[question.name]}
          state={state}
          last={last}
          values={inputValues}
          groupTitle={group && group.label && group.label != groupTitle ? group.label : null}
          onSubmit={(value) => {
            let newValues = {...inputValues};
            newValues[question.name] = value;
            setInputValues(newValues);
            if (last) setValues(inputValues);
          }}
          onCancel={prevQuestion ? (value) => {
            let newValues = {...inputValues};
            delete newValues[prevQuestion.name];
            setInputValues(newValues);
          } : null}
        />
      )
      if (group && group.label && group.label != groupTitle) {
        groupTitle = group.label;
      }
    }
    return els;
  }

  return (
    <div className="GradeableQuestionnaire">
      {getCurrentQuestions()}
    </div>
  );

}