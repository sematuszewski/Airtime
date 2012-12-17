<?php
class UserRestController extends Zend_Rest_Controller{
    public function init()
    {
        $this->_helper->viewRenderer->setNoRender(true);
        $this->_helper->layout->disableLayout();
    }

    public function indexAction()
    {
        $data = Application_Model_User::getAllUsers();
        echo json_encode($data);
    }

    public function getAction()
    {
        $id = $this->_request->get('id');
        $data = Application_Model_User::getUserData($id);
        echo json_encode($data);
    }

    public function postAction()
    {
        $postParams = file_get_contents("php://input");
        // server side validation
        $data = json_decode($postParams, true);
        if (Application_Model_User::isLoginExist($data['login'])) {
            $error = array('login' => _("Login already exists"));
            $this->getResponse()
                ->setHttpResponseCode(400)
                ->appendBody(json_encode($error));
        } else {
            // create new user
            $user = new Application_Model_User(null);
            $user->updateUser($data);
            $this->getResponse()
                ->setHttpResponseCode(200);
        }
    }

    public function putAction()
    {
        try{
            $data = json_decode($this->getRequest()->getRawBody(), true);
            
            $user = new Application_Model_User($data['id']);
            $user->updateUser($data);
            $this->getResponse()
                ->setHttpResponseCode(200);
        } catch( Exception $e){
            $this->getResponse()
                ->setHttpResponseCode(400)
                ->appendBody("unable to process put requests. Please try later");
        }
    }

    public function deleteAction()
    {
        try{
            $id = $this->_request->get('id');
            $user = new Application_Model_User($id);
            $user->delete();
            $this->getResponse()
                ->setHttpResponseCode(200);
        } catch( Exception $e){
            $this->getResponse()
            ->setHttpResponseCode(400)
            ->appendBody("unable to process delete requests. Please try later");
        }
    }
}