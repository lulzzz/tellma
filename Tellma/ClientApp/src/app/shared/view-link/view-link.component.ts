import { Component, OnInit, HostBinding, Input } from '@angular/core';

@Component({
  selector: 't-view-link',
  templateUrl: './view-link.component.html'
})
export class ViewLinkComponent implements OnInit {

  @Input()
  link: string;

  @Input()
  itemId: string | number;

  @HostBinding('class.w-100')
  w100 = true;

  constructor() { }

  ngOnInit() {
  }

}
