<?php

class StaticcontentController extends Zend_Controller_Action
{
    public function __call($method, $args)
    {
        if ('Action' == substr($method, -6))
        {
            $action = $this->getRequest()->getActionName();
            return $this->render($action);
        }
    }
}

class TemplateController extends StaticcontentController
{
    public function init()
    {
        $this->view->layout()->disableLayout();
        $this->_helper->viewRenderer->setNoRender(true);
        $ajaxContext = $this->_helper->getHelper('AjaxContext');
        $ajaxContext->addActionContext('get-template', 'json');
    }
}