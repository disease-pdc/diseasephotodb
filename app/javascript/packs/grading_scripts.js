import $ from "cash-dom"

const showEverted = () => {
  $('.section-everted-no').removeClass('d-block')
  $('.section-everted-no').addClass('d-none')
  $('.section-everted').removeClass('d-none')
  $('.section-everted').addClass('d-block')
  if (
    $("input[name='grading_data[tf_grade]']:checked").length < 1 ||
    $("input[name='grading_data[ti_grade]']:checked").length < 1 ||
    $("input[name='grading_data[ts_grade]']:checked").length < 1
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
    $("input[name='grading_data[upper_lid_tt_grade]']:checked").length < 1 ||
    $("input[name='grading_data[lower_lid_tt_grade]']:checked").length < 1
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