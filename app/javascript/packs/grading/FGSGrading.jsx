import React, { useEffect, useRef, useState } from 'react'
import ReactDOM from 'react-dom'

import { GradeableImages } from './GradeableImages'
import { GradeableQuestionnaire } from './GradeableQuestionnaire'

const selected = (values, key, value) => {
  return values[key] && (
    (Array.isArray(values[key]) && values[key].indexOf(value) > -1) ||
    (values[key] === value)
  )
    
}

const Options = {
  image: [
    {value: '1', label: 'Yes'},
    {value: '-1', label: 'No, not available'},
    {value: '0', label: 'No, unclear image'}
  ],
  yesno: [
    {value: '1', label: 'Yes'},
    {value: '0', label: 'No'}
  ],
  location: [
    {value: 'left_lateral_fornix', label: 'Left lateral fornix'},
    {value: 'right_lateral_fornix', label: 'Right lateral fornix'},
    {value: 'anterior_fornix', label: 'Anterior fornix'},
    {value: 'posterior_fornix', label: 'Posterior fornix'},
    {value: 'cervix_q1', label: 'Cervix Q1'},
    {value: 'cervix_q2', label: 'Cervix Q2'},
    {value: 'cervix_q3', label: 'Cervix Q3'},
    {value: 'cervix_q4', label: 'Cervix Q4'},
    {value: 'vaginal_walls', label: 'Vaginal walls'}
  ],
  sti: [
    {value: 'suspected_bacterial_vaginosis', label: 'Suspected Bacterial Vaginosis'},
    {value: 'suspected_trichomonas', label: 'Suspected Trichomonas'},
    {value: 'candidiasis', label: 'Candidiasis'},
    {value: 'suspected_gonorrhoea', label: 'Suspected Gonorrhoea'},
    {value: 'suspected_chlamydia', label: 'Suspected Chlamydia'},
    {value: 'suspected_herpes', label: 'Suspected Herpes'},
    {value: 'genital_warts', label: 'Genital Warts'},
    {value: 'chancroid', label: 'Chancroid'}
  ],
  repro: [
    {value: 'buboes', label: 'Buboes'},
    {value: 'lymphogranuloma', label: 'Lymphogranuloma'},
    {value: 'scabies', label: 'Scabies'},
    {value: 'crabs', label: 'Crabs'},
    {value: 'polyp', label: 'Polyp'},
    {value: 'ectropion', label: 'Ectropion'},
    {value: 'nabothian_cyst', label: 'Nabothian Cyst'},
    {value: 'prolapsed_uterus', label: 'Prolapsed Uterus'},
    {value: 'other_please_list', label: 'Other: please list'}
  ],
  sti_repro: [
    {value: '1', label: 'Cervicitis'},
    {value: '2', label: 'Suspected Trichomonas'},
    {value: '3', label: 'Candidiasis'},
    {value: '4', label: 'Suspected Herpes'},
    {value: '5', label: 'Genital Warts'},
    {value: '6', label: 'Chancroid'},
    {value: '7', label: 'Buboes'},
    {value: '8', label: 'Lymphogranuloma'},
    {value: '9', label: 'Scabies'},
    {value: '10', label: 'Crabs'},
    {value: '11', label: 'Polyp'},
    {value: '12', label: 'Ectropion'},
    {value: '13', label: 'Nabothian Cyst'},
    {value: '14', label: 'Prolapsed Uterus'},
    {value: '95', label: 'Other: please list'}
  ]
}
const Groups = [
  {
    name: 'image_quality',
    label: 'Image Quality'
  }, {
    name: 'exam_findings',
    label: 'FGS Examination Findings',
    relevant: ({cervical_images_assessed, vaginal_wall_images_assessed}) => (
      cervical_images_assessed === '1' || vaginal_wall_images_assessed === '1'
    ) 
  }, {
    name: 'results',
    label: 'Results',
    relevant: ({cervical_images_assessed, vaginal_wall_images_assessed}) => (
      cervical_images_assessed === '1' || vaginal_wall_images_assessed === '1'
    ) 
  }
]
const Questions = [
  {
    group: 'image_quality',
    type: 'select_one',
    options: Options.image,
    name: 'cervical_images_assessed',
    label: 'Were cervical images able to be assessed?',
    required: true
  }, {
    group: 'image_quality',
    type: 'text',
    name: 'cervical_image_comments',
    label: 'Please enter any comments about cervical image quality.',
    required: false
  }, {
    group: 'image_quality',
    type: 'select_one',
    options: Options.image,
    name: 'vaginal_wall_images_assessed',
    label: 'Were vaginal wall images able to be assessed?',
    required: true
  }, {
    group: 'image_quality',
    type: 'text',
    name: 'image_comments',
    label: 'Please enter any comments about vaginal wall image quality.',
    required: false
  }, {
    group: 'exam_findings',
    type: 'select_one',
    options: Options.yesno,
    name: 'grainy_sandy_patches',
    label: 'Grainy sandy patches',
    required: true
  }, {
    group: 'exam_findings',
    type: 'select_multiple',
    options: Options.location,
    name: 'location_grainy_sandy_patches',
    label: 'Specify Location: Grainy Sandy Patches',
    relevant: values => values.grainy_sandy_patches === '1',
    required: true
  }, {
    group: 'exam_findings',
    type: 'select_one',
    options: Options.yesno,
    name: 'homogeneous_yellow_patches',
    label: 'Homogeneous yellow patches',
    required: true
  }, {
    group: 'exam_findings',
    type: 'select_multiple',
    options: Options.location,
    name: 'location_homogeneous_yellow',
    label: 'Specify Location: Homogeneous Yellow Patches',
    relevant: values => values.homogeneous_yellow_patches === '1',
    required: true
  }, {
    group: 'exam_findings',
    type: 'select_one',
    options: Options.yesno,
    name: 'rubbery_papules',
    label: 'Rubbery papules',
    required: true
  }, {
    group: 'exam_findings',
    type: 'select_multiple',
    options: Options.location,
    name: 'location_rubbery_papules',
    label: 'Specify Location: Rubbery papules',
    relevant: values => values.rubbery_papules === '1',
    required: true
  }, {
    group: 'exam_findings',
    type: 'select_one',
    options: Options.yesno,
    name: 'abnormal_blood_vessels',
    label: 'Abnormal blood vessels',
    required: true
  }, {
    group: 'exam_findings',
    type: 'select_multiple',
    options: Options.location,
    name: 'location_abnormal_blood_vessel',
    label: 'Specify Location: Abnormal blood vessels',
    relevant: values => values.abnormal_blood_vessels === '1',
    required: true
  }, {
    group: 'results',
    type: 'select_one',
    options: Options.yesno,
    name: 'fgs_status',
    label: 'Does the patient have FGS?',
    constraint: (value, values) => {
      return (
        (
          selected(values, 'grainy_sandy_patches', '1') ||
          selected(values, 'homogeneous_yellow_patches', '1') ||
          selected(values, 'rubbery_papules', '1') ||
          selected(values, 'abnormal_blood_vessels', '1')
        ) && 
        value === '1'
      ) || 
      (
        (
          selected(values, 'grainy_sandy_patches', '0') &&
          selected(values, 'homogeneous_yellow_patches', '0') &&
          selected(values, 'rubbery_papules', '0') &&
          selected(values, 'abnormal_blood_vessels', '0')
        ) && 
        value === '0'
      );
    },
    constraint_message: "Must select: 'Yes' if patient has any of: grainy sandy patches, homogeneous yellow patches, rubbery papules, abnormal blood vessels, or must select 'No' if none of those conditions are present.",
    required: true
  }, {
    group: 'results',
    type: 'select_one',
    options: Options.yesno,
    name: 'sus_sti_repro',
    label: 'Does the patient have any suspected reproductive health problem, includings STIs?',
    required: true
  }, {
    group: 'results',
    type: 'select_multiple',
    options: Options.sti_repro,
    name: 'sti_repro_list',
    label: 'Specify suspected reproductive health problem',
    relevant: values => values.sus_sti_repro === '1',
    required: true
  },  {
    group: 'results',
    type: 'text',
    name: 'repro_other_desc',
    label: 'Please list other',
    relevant: values => (
      selected(values, 'sti_repro_list', '95')
    ),
    required: true
  }, {
    group: 'results',
    type: 'text',
    name: 'additional_comments',
    label: 'Please enter any additional comments',
    required: false
  }
];


export const FGSGrading = ({
  authenticityToken,
  gradingSetImage,
  submitUrl
}) => {

  const [gradingData, setGradingData] = useState({});
  const formRef = useRef(null);
  const gradingDataInputRef = useRef(null);

  const setCurrentValues = (values) => {
    setGradingData(values)
    gradingDataInputRef.current.value = JSON.stringify(values)
    formRef.current.submit()
  }

  return (
    <div className="FGSGrading">
      <div className="row">
        <div className="col-lg-5">
          <GradeableImages gradingSetImage={gradingSetImage} />
        </div>
        <div className="col-lg-7">
          <GradeableQuestionnaire
            groups={Groups}
            questions={Questions}
            gradeable={gradingSetImage}
            values={gradingData}
            setValues={setCurrentValues}
          />
        </div>
      </div>
      <form ref={formRef} method="POST" action={submitUrl} style={{display: 'none'}}>
        <input type="hidden" name="grading_set_image_id" 
          value={gradingSetImage.id}
        />
        <input type="hidden" name="grading_data"
          ref={gradingDataInputRef}
          value={JSON.stringify(gradingData)}
        />
      </form>
    </div>
  )
}