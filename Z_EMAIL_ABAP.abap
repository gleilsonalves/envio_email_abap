REPORT z_email_abap.

CLASS cl_main DEFINITION.

  PUBLIC SECTION.

    DATA: gx_bcs_exception TYPE REF TO cx_bcs.

    METHODS:
      sender_email    RETURNING VALUE(rv_sender)    TYPE ad_smtpadr,
      recipient_email RETURNING VALUE(rv_recipient) TYPE ad_smtpadr,
      subject_email   RETURNING VALUE(rv_subject)   TYPE so_obj_des,
      body_email      RETURNING VALUE(rt_body)      TYPE soli_tab,
      envia_email     IMPORTING iv_sender_email   TYPE ad_smtpadr
                                iv_subject        TYPE so_obj_des
                                iv_recipient_mail TYPE ad_smtpadr
                                it_body           TYPE soli_tab OPTIONAL
                      EXPORTING ev_sent           TYPE boolean.

ENDCLASS.

CLASS cl_main IMPLEMENTATION.

  METHOD envia_email.

    TRY .
* Criação do objeto e-mail para envio
        DATA(ol_send_request) = cl_bcs=>create_persistent( ).

* E-mail remetente
        DATA(ol_sender) = cl_cam_address_bcs=>create_internet_address( iv_sender_email ).
        ol_send_request->set_sender( i_sender = ol_sender ).

* E-mail de destino
        DATA(ol_recipient) = cl_cam_address_bcs=>create_internet_address( iv_recipient_mail ).

        ol_send_request->add_recipient(
          EXPORTING
            i_recipient = ol_recipient
            i_express   = abap_true
        ).

* Corpo do e-mail
        DATA(ol_document) = cl_document_bcs=>create_document( i_type    = 'HTM'
                                                              i_text    = it_body
                                                              i_length  = '90'
                                                              i_subject = iv_subject ).
* Anexa o documento criado ao objeto de e-mail
        ol_send_request->set_document( ol_document ).

* Dispara o envio do e-mail
        ev_sent = ol_send_request->send( ).

        IF ev_sent IS NOT INITIAL.
* Efetiva o envio do e-mail.
          COMMIT WORK.
          WRITE: 'E-mail enviado!'.

        ENDIF.

      CATCH cx_bcs INTO me->gx_bcs_exception.
* Capta e mostra na tela a mensagem de erro da exceção diaparada
        DATA(l_error_desc) = gx_bcs_exception->get_text( ).
        WRITE: 'ERROR: ' && | { l_error_desc } |.

    ENDTRY.

  ENDMETHOD.

  METHOD sender_email.

* Define remetente
    rv_sender = 'gleilsonalves@abap.com'.

  ENDMETHOD.

  METHOD recipient_email.

* Define destinatário
    rv_recipient = 'testes_abap@abap.com'.

  ENDMETHOD.

  METHOD subject_email.

* Assunto do e-mail
    rv_subject = 'Titulo para testes de envio de e-mail com ABAP'.

  ENDMETHOD.

  METHOD body_email.

* Texto do corpo do e-mail
    APPEND INITIAL LINE TO rt_body ASSIGNING FIELD-SYMBOL(<body>).
    <body>-line = '<html><head><body><h1>Corpo do email teste</h1></body></head></html>'.

  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.

* Instancia o objeto CL_MAIN
  DATA(o_main) = NEW cl_main( ).

* Chama o método ENVIA_EMAIL e para cada parâmetro é diaparado um metodo correspondente
  o_main->envia_email(
    EXPORTING
      iv_sender_email   = o_main->sender_email( )
      iv_subject        = o_main->subject_email( )
      iv_recipient_mail = o_main->recipient_email( )
      it_body           = o_main->body_email( )
  ).
