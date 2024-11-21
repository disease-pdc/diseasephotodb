import React, { useEffect, useState, useRef } from 'react'

import { Question } from './Question'

export const GradeableQuestionnaire = ({
  groups,
  questions,
  gradeable,
  values,
  setValues
}) => {

  const [inputValues, setInputValues] = useState(values);
  const elRef = useRef()

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

  const getCurrentQuestionData = () => {
    let currentQuestions = [];
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
    return currentQuestions
  }

  const getCurrentQuestions = () => {
    const currentQuestions = getCurrentQuestionData();
    let groupTitle = null;
    
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

  const confirmNavAway = () => {
    const currentQuestions = getCurrentQuestionData();
    const lastIndex = currentQuestions.length - 1;
    const last = currentQuestions[lastIndex].state != 'current';
    if (!last) {
      return "Are you sure you want to navigate away from this page?\n\nAny responses entered will not be saved.\n\nPress OK to continue or Cancel to stay on the current page.";
    }
  }

  useEffect(() => {
    window.onbeforeunload = confirmNavAway;
    return () => { window.onbeforeunload = null; };
  }, [confirmNavAway]);

  useEffect(() => {
    elRef.current?.scrollIntoView({block: "end", inline: "nearest"})
  }, [inputValues])

  return (
    <div className="GradeableQuestionnaire" ref={elRef}>
      {getCurrentQuestions()}
    </div>
  );

}