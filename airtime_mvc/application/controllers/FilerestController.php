<?php
class FileRestController extends Zend_Rest_Controller{
    public function init()
    {
        $this->_helper->viewRenderer->setNoRender(true);
    }
    
    public function indexAction()
    {
        echo "Get all data", PHP_EOL;
        $this->_helper->viewRenderer->setNoRender(true);
        $this->_helper->layout->disableLayout();
    }
    
    public function getAction()
    {
        echo "Get data with ID " . $this->_request->get('id'), PHP_EOL;
        $this->_helper->viewRenderer->setNoRender(true);
        $this->_helper->layout->disableLayout();
    }
    
    public function postAction()
    {
        echo "Add new data ", PHP_EOL;
        print_r($_POST);
        $this->_helper->viewRenderer->setNoRender(true);
        $this->_helper->layout->disableLayout();
    }
    
    public function putAction()
    {
        echo "Update data with ID " . $this->_request->get('id'), PHP_EOL;
        $this->_helper->viewRenderer->setNoRender(true);
        $this->_helper->layout->disableLayout();
    }
    
    public function deleteAction()
    {
        echo "Delete data with ID " . $this->_request->get('id'), PHP_EOL;
        $this->_helper->viewRenderer->setNoRender(true);
        $this->_helper->layout->disableLayout();
    }
}