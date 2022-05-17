import $ from "cash-dom"

const noSelection = (selector) => {
  return $(selector) == null || $(selector).length < 1
}

const showEverted = () => {
  $('.section-everted-no').removeClass('d-block')
  $('.section-everted-no').addClass('d-none')
  $('.section-everted').removeClass('d-none')
  $('.section-everted').addClass('d-block')
  if (
    noSelection("input[name='grading_data[photo_quality]']:checked") ||
    noSelection("input[name='grading_data[tf_grade]']:checked") ||
    noSelection("input[name='grading_data[ti_grade]']:checked") ||
    noSelection("input[name='grading_data[ts_grade]']:checked")
  ) {
    $(".submit-grading").prop("disabled", true);
  } else {
    $(".submit-grading").prop("disabled", false);
  }
}

const showEvertedNo = () => {
  $('.section-everted-no').removeClass('d-none')
  $('.section-everted-no').addClass('d-block')
  $('.section-everted').removeClass('d-block')
  $('.section-everted').addClass('d-none')
  if (
    noSelection("input[name='grading_data[photo_quality]']:checked") ||
    noSelection("input[name='grading_data[upper_lid_tt_grade]']:checked") ||
    noSelection("input[name='grading_data[lower_lid_tt_grade]']:checked")
  ) {
    $(".submit-grading").prop("disabled", true);
  } else {
    $(".submit-grading").prop("disabled", false);
  }
}

$(function () {

  $("input").on('change', (e) => {
    const val = $("input[name='grading_data[is_everted]']:checked").val() 
    if (val === "1") {
      showEverted()
    } else if (val === "0") {
      showEvertedNo()
    }
  })

});