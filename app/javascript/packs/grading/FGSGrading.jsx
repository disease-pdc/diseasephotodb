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
  expert_reviewer: [
    {value: 'expert_reviewer_1', label: 'Amaya Bustinduy'},
    {value: 'expert_reviewer_2', label: 'Albert Kihunrwa'},
    {value: 'expert_reviewer_3', label: 'Edgar Ndaboine'},
    {value: 'expert_reviewer_4', label: 'Bellington Vwalika'},
    {value: 'expert_reviewer_5', label: 'Amina Yussuph'},
    {value: 'other_expert_reviewer', label: 'Other expert reviewer'}
  ],
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
  ]
}
const Groups = [
  {
    name: 'image_quality',
    label: 'Image Quality'
  }, {
    name: 'exam_findings',
    label: 'FGS Examination Findings',
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
    name: 'name_of_expert_reviewer',
    type: 'select_one',
    options: Options.expert_reviewer,
    label: 'Name of expert reviewer',
    required: true
  }, {
    type: 'text',
    name: 'other_expert_reviewer',
    label: 'Name of If other expert reviewer that is not in the proposed list enter the name reviewer',
    hint: 'All name must be in CAPITAL letters',
    relevant: (values) => {
      return values.name_of_expert_reviewer === 'other_expert_reviewer'
    },
    required: true
  }, {
    type: 'text',
    name: 'pid',
    label: 'Participant ID',
    hint: 'Participant ID must be in the format FGS-T-XXXX, where XXXX is a four-digit number',
    constraint: (value, values) => {
      return /^FGS-T-[0-9]{4}$/.test(value)
    },
    constraint_message: 'Participant ID is not in the correct format. Ensure that the ID is typed correctly and that there are no extra spaces before or after the ID',
    required: true
  }, {
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
    name: 'suspected_sti',
    label: 'Does the patient have a suspected STI?',
    required: true
  }, {
    group: 'results',
    type: 'select_multiple',
    options: Options.sti,
    name: 'specify_suspected_sti',
    label: 'Specify suspected STI',
    relevant: values => values.suspected_sti === '1',
    required: true
  }, {
    group: 'results',
    type: 'select_one',
    options: Options.yesno,
    name: 'other_reproductive_problem',
    label: 'Does the patient have any other reproductive health problem?',
    required: true
  }, {
    group: 'results',
    type: 'select_multiple',
    options: Options.repro,
    name: 'specify_reproductive_problem',
    label: 'Specify suspected reproductive health problem',
    relevant: values => values.other_reproductive_problem === '1',
    required: true
  }, {
    group: 'results',
    type: 'text',
    name: 'list_other_reproductive_problem',
    label: 'Please list other',
    relevant: values => (
      selected(values, 'specify_reproductive_problem', 'other_please_list')
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

  const confirmNavAway = () => {
    const message = "Are you sure you want to navigate away from this page?\n\nAny responses entered will not be saved.\n\nPress OK to continue or Cancel to stay on the current page.";
    if (confirm(message)) return true;
    else return false;
  }


  useEffect(() => {
    window.onbeforeunload = confirmNavAway;
    return () => { window.onbeforeunload = null; };
  }, [confirmNavAway]);

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