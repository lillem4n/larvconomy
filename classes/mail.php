<?php defined('SYSPATH') or die('No direct script access.');

class Mail extends Controller {

  private $to = "";
  private $from = Array();
  private $subject = "";
  private $message = "";
  private $attachment = "";
  private $attname = "";

  public function __construct()
  {
        
  }
      
  public function to($to)
  {
    $this->to = $to;
  }

  public function from($name, $email)
  {
    $this->from['name'] = $name;
    $this->from['email'] = $email;
  }

  public function subject($subject) 
  {
    $this->subject = $subject;
  }

  public function content($message) 
  {
    $this->message = $message;
  }

  public function attachment($fileURL)
  {
    $file = fopen($fileURL, 'rb');
    $fileContent = stream_get_contents($file);
    fclose($file);

    $this->attachment = $fileContent;
    $this->attname = basename($fileURL);
  }
  
  public function send()
  {
      $header = 'From: "'.$this->from['name'].'" <'.$this->from['email'].'>\r\n';
      $header .= 'Reply-To: '.$this->from['email'].'\r\n';
      $header .= 'Content-Type: text/plain; charset=UTF-8\r\n' .
                 'Content-Transfer-Encoding: base64\r\n\r\n'; 

      $content = "";
      if($this->attachment)
      {
        $semi_rand = md5(time());
        $mime_boundary = '==Multipart_Boundary_x'.$semi_rand.'x';

        $header .= '\nMIME-Version: 1.0\n' .
                    'Content-Type: multipart/mixed;\n' .
                    'boundary=" '. $mime_boundary .'"';

        $this->attachment = chunk_split(base64_encode($this->attachment));
        $content .= '–'.$mime_boundary.'\n' .
                    'Content-Type: application/pdf;\n' .
                    'name="'. $this->attname  .'"\n' .
                    'Content-Disposition: attachment;\n' .
                    'filename= "'. $this->attname .'"\n' .
                    'Content-Transfer-Encoding: base64\n\n' .
                    $this->attachment . '\n\n' .
                    '-'.$mime_boundary.'-\n';
      }
      if( mail($this->to,$this->subject, $this->message, $header) )
      {
        return TRUE; 
      }
      else
      {
        return FALSE;
      }
  }

}
